from caravel_cocotb.caravel_interfaces import * # import python APIs
import cocotb

from designs_tests.MatrixMonSTARS_test import MatrixMonSTARS_test

@cocotb.test() # cocotb test marker
@report_test # wrapper for configure test reporting files
async def stars_tests(dut):
    caravelEnv = await test_configure(dut)
    await caravelEnv.wait_mgmt_gpio(1)

    # 6: MatrixMonSTARS
    cocotb.log.info(f"[TB_TOP] Starting SillySynth test (<This number is wrong right now>)")
    caravelEnv.drive_gpio_in((37,34), 0x6)
    await SillySynth_test()
