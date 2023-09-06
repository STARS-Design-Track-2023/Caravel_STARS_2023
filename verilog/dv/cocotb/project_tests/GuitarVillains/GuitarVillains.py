from caravel_cocotb.caravel_interfaces import * # import python APIs
import cocotb

caravelEnv : Caravel_env = None
half_clk_period : int = 0

@cocotb.test() # cocotb test marker
@report_test # wrapper for configure test reporting files
async def GuitarVillains(dut):
    cocotb.log.info("[5] Start configuration")
    caravelEnv = await test_configure(dut, timeout_cycles=2000000)
    cocotb.log.info("[5] Await mgmt_gpio")
    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    cocotb.log.info("[5] Finish configuration")
    half_clk_periodclk_period = caravelEnv.get_clock_period() / 2

    cocotb.log.info(f"[5] T1: Power-on-reset")
    # reset design
    caravelEnv.drive_gpio_in((3,0), 0x0)
