#include <firmware_apis.h>

void main() {
    ManagmentGpio_outputEnable();
    ManagmentGpio_write(0);
    enableHkSpi(0);
    GPIOs_configureAll(GPIO_MODE_USER_STD_BIDIRECTIONAL);
    GPIOs_loadConfigs();
    LogicAnalyzer_inputEnable(LA_REG_0, 0xf);
    LogicAnalyzer_write(LA_REG_0, 11);
    ManagmentGpio_write(1);
    return;
}
