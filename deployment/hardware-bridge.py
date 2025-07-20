#!/usr/bin/env python3

"""
Hardware Bridge for Raspberry Pi Kiosk
Connects local GPIO to production API
"""

import requests
import time
import json
import sys
import logging
from threading import Thread

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Try to import RPi.GPIO
try:
    import RPi.GPIO as GPIO
    GPIO_AVAILABLE = True
    logger.info("GPIO hardware detected")
except ImportError:
    GPIO_AVAILABLE = False
    logger.warning("GPIO not available - running in simulation mode")

class HardwareBridge:
    def __init__(self):
        self.api_base = "https://smart-beverage-dispenser-uzisinapoj.replit.app/api"
        self.hardware_pins = {
            'valve_1': 18,
            'valve_2': 19,
            'valve_3': 20,
            'valve_4': 21,
            'flow_sensor_1': 22,
            'flow_sensor_2': 23,
            'flow_sensor_3': 24,
            'flow_sensor_4': 25
        }
        self.dispensing = False
        
        if GPIO_AVAILABLE:
            self.setup_gpio()
    
    def setup_gpio(self):
        """Initialize GPIO pins"""
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        
        # Setup valve pins as outputs
        for pin_name, pin_num in self.hardware_pins.items():
            if 'valve' in pin_name:
                GPIO.setup(pin_num, GPIO.OUT, initial=GPIO.LOW)
                logger.info(f"Configured {pin_name} on pin {pin_num}")
        
        # Setup flow sensor pins as inputs (if implementing)
        for pin_name, pin_num in self.hardware_pins.items():
            if 'flow_sensor' in pin_name:
                GPIO.setup(pin_num, GPIO.IN, pull_up_down=GPIO.PUD_UP)
    
    def control_valve(self, valve_pin, state, duration=0):
        """Control a specific valve"""
        if GPIO_AVAILABLE:
            GPIO.output(valve_pin, GPIO.HIGH if state else GPIO.LOW)
            logger.info(f"Valve on pin {valve_pin}: {'ON' if state else 'OFF'}")
            
            if state and duration > 0:
                time.sleep(duration)
                GPIO.output(valve_pin, GPIO.LOW)
                logger.info(f"Valve on pin {valve_pin}: OFF (after {duration}s)")
        else:
            logger.info(f"SIMULATION: Valve {valve_pin} {'ON' if state else 'OFF'} for {duration}s")
            if state and duration > 0:
                time.sleep(duration)
    
    def poll_for_orders(self):
        """Poll the production API for pending orders"""
        while True:
            try:
                # Check for orders marked as 'confirmed' (ready to dispense)
                response = requests.get(f"{self.api_base}/admin/orders?status=confirmed", timeout=5)
                
                if response.status_code == 200:
                    orders = response.json()
                    
                    for order in orders:
                        if not self.dispensing:
                            self.process_order(order)
                
                time.sleep(2)  # Poll every 2 seconds
                
            except requests.exceptions.RequestException as e:
                logger.error(f"API polling error: {e}")
                time.sleep(5)  # Wait longer on error
            except Exception as e:
                logger.error(f"Unexpected error: {e}")
                time.sleep(5)
    
    def process_order(self, order):
        """Process a dispensing order"""
        self.dispensing = True
        order_id = order.get('id')
        items = order.get('items', [])
        
        logger.info(f"Processing order {order_id} with {len(items)} items")
        
        try:
            # Update order status to 'dispensing'
            requests.patch(f"{self.api_base}/admin/orders/{order_id}", 
                         json={'status': 'dispensing'}, timeout=5)
            
            # Process each item
            for item in items:
                beverage_id = item.get('beverageId')
                quantity = item.get('quantity', 1)
                
                # Get beverage info including hardware pin
                bev_response = requests.get(f"{self.api_base}/beverages/{beverage_id}", timeout=5)
                if bev_response.status_code == 200:
                    beverage = bev_response.json()
                    valve_pin = beverage.get('valvePin')
                    
                    if valve_pin:
                        # Calculate dispensing time (assume 5 seconds per 0.2L)
                        dispense_time = quantity * 5  # 5 seconds per cup
                        
                        logger.info(f"Dispensing {beverage.get('name')} for {dispense_time}s")
                        self.control_valve(valve_pin, True, dispense_time)
            
            # Mark order as completed
            requests.patch(f"{self.api_base}/admin/orders/{order_id}", 
                         json={'status': 'completed'}, timeout=5)
            
            logger.info(f"Order {order_id} completed successfully")
            
        except Exception as e:
            logger.error(f"Error processing order {order_id}: {e}")
            # Mark order as failed
            try:
                requests.patch(f"{self.api_base}/admin/orders/{order_id}", 
                             json={'status': 'failed'}, timeout=5)
            except:
                pass
        
        finally:
            self.dispensing = False
    
    def cleanup(self):
        """Cleanup GPIO on exit"""
        if GPIO_AVAILABLE:
            GPIO.cleanup()

def main():
    bridge = HardwareBridge()
    
    logger.info("Hardware Bridge starting...")
    logger.info(f"Connecting to API: {bridge.api_base}")
    
    try:
        # Test API connectivity
        response = requests.get(f"{bridge.api_base}/beverages", timeout=5)
        if response.status_code == 200:
            logger.info("API connection successful")
        else:
            logger.error("API connection failed")
            sys.exit(1)
        
        # Start polling for orders
        bridge.poll_for_orders()
        
    except KeyboardInterrupt:
        logger.info("Shutting down...")
    except Exception as e:
        logger.error(f"Fatal error: {e}")
    finally:
        bridge.cleanup()

if __name__ == "__main__":
    main()