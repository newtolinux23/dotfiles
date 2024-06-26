import speedtest
import logging
import time
import os

# Configure logging
log_file = "/var/log/internet-monitoring/internet_monitoring.log"
logging.basicConfig(filename=log_file, level=logging.DEBUG, 
                    format='%(asctime)s - %(levelname)s - %(message)s')

logging.debug("Starting internet monitoring script")

def test_internet_speed():
    logging.debug("Starting internet speed test")
    try:
        st = speedtest.Speedtest()
        st.download()
        st.upload()
        result = st.results.dict()
        logging.info(f"Download: {result['download'] / 1_000_000:.2f} Mbps, Upload: {result['upload'] / 1_000_000:.2f} Mbps, Ping: {result['ping']} ms")
    except Exception as e:
        logging.error(f"Failed to test internet speed: {e}")

def main():
    logging.debug("Entering main loop")
    while True:
        test_internet_speed()
        logging.debug("Sleeping for 1 hour")
        time.sleep(3600)  # Sleep for 1 hour

if __name__ == "__main__":
    main()
