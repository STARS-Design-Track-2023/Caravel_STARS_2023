from caravel_cocotb.caravel_interfaces import * # import python APIs
import cocotb

caravelEnv : Caravel_env = None
half_clk_period : int = 0

async def GuitarVillains_test(caravelEnv_pass : Caravel_env):
    caravelEnv = caravelEnv_pass
    if (caravelEnv == None):
        cocotb.log.error(f"[5] Invalid caravelEnv")
        return
    half_clk_periodclk_period = caravelEnv.get_clock_period() / 2

    cocotb.log.info(f"[5] T1: Power-on-reset")
    # reset design
    caravelEnv.drive_gpio_in((3,0), 0x0)
