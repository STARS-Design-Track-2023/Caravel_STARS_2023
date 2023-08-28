#include <firmware_apis.h> 
void main() {
  ManagmentGpio_outputEnable();
  ManagmentGpio_write(0);
  enableHkSpi(0); 
  GPIOs_configureAll(GPIO_MODE_USER_STD_BIDIRECTIONAL);
  GPIOs_configure(34, GPIO_MODE_USER_STD_INPUT_PULLDOWN);
  GPIOs_configure(35, GPIO_MODE_USER_STD_INPUT_PULLDOWN);
  GPIOs_configure(36, GPIO_MODE_USER_STD_INPUT_PULLDOWN);
  GPIOs_configure(37, GPIO_MODE_USER_STD_INPUT_PULLDOWN);
  GPIOs_loadConfigs();
  ManagmentGpio_write(1);
  return;
}
