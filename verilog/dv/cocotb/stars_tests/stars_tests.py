from caravel_cocotb.caravel_interfaces import * # import python APIs
import cocotb

from designs_tests.GuitarVillains_test import GuitarVillains_test
from designs_tests.MatrixMonSTARS_test import MatrixMonSTARS_test

@cocotb.test() # cocotb test marker
@report_test # wrapper for configure test reporting files
async def stars_tests(dut):
    cocotb.log.info("[TB_TOP] Start configuration")
    caravelEnv = await test_configure(dut, timeout_cycles=2000000)
    cocotb.log.info("[TB_TOP] Await mgmt_gpio")
    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    cocotb.log.info("[TB_TOP] Finish configuration")

    # 1: Absentees
    cocotb.log.info(f"[TB_TOP] Starting Absentees test (1)")
    caravelEnv.drive_gpio_in((37,34), 0x1)
    # call test

    # 2: DigiDoggs
    cocotb.log.info(f"[TB_TOP] Starting DigiDoggs test (2)")
    caravelEnv.drive_gpio_in((37,34), 0x2)
    # call test

    # 3: EightyTwos
    cocotb.log.info(f"[TB_TOP] Starting EightyTwos test (3)")
    caravelEnv.drive_gpio_in((37,34), 0x3)
    # call test

    # 4: Geriatrics
    cocotb.log.info(f"[TB_TOP] Starting Geriatrics test (4)")
    caravelEnv.drive_gpio_in((37,34), 0x4)
    # call test

    # 5: GuitarVillains
    cocotb.log.info(f"[TB_TOP] Starting GuitarVillains test (5)")
    caravelEnv.drive_gpio_in((37,34), 0x5)
    await GuitarVillains_test(caravelEnv)

    # 6: MatrixMonSTARS
    cocotb.log.info(f"[TB_TOP] Starting MatrixMonSTARS test (6)")
    caravelEnv.drive_gpio_in((37,34), 0x6)
    await MatrixMonSTARS_test(caravelEnv)

    # 7: Outel
    cocotb.log.info(f"[TB_TOP] Starting Outel test (7)")
    caravelEnv.drive_gpio_in((37,34), 0x7)
    # call test

    # 8: SaSS
    cocotb.log.info(f"[TB_TOP] Starting SaSS test (8)")
    caravelEnv.drive_gpio_in((37,34), 0x8)
    # call test

    # 9: Triple-SSS
    cocotb.log.info(f"[TB_TOP] Starting Triple-SSS test (9)")
    caravelEnv.drive_gpio_in((37,34), 0x9)
    # call test

    # 10: SyntheSTARS
    cocotb.log.info(f"[TB_TOP] Starting SyntheSTARS test (10)")
    caravelEnv.drive_gpio_in((37,34), 0xa)
    # call test

    # 11: SynthSurgeons
    cocotb.log.info(f"[TB_TOP] Starting SynthSurgeons test (11)")
    caravelEnv.drive_gpio_in((37,34), 0xb)
    # call test

    # 12: TMNT
    cocotb.log.info(f"[TB_TOP] Starting TMNT test (12)")
    caravelEnv.drive_gpio_in((37,34), 0xc)
    # call test
