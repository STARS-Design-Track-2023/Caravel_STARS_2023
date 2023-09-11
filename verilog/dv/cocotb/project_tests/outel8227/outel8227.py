# from caravel_cocotb.caravel_interfaces import test_configure
# from caravel_cocotb.caravel_interfaces import report_test
# import cocotb 

# class Memory:
#     mem = [0 for _ in range(2**16)]

#     async def read_mem(high, low):
#         await cocotb.triggers.Timer(time=150, units='ns')
#         return mem[int(high + low[2:], 2)]

#     async def write_mem(high, low, data):
#         await cocotb.triggers.Timer(time=150, units='ns')
#         mem[int(high + low[2:], 2)] = data
    

# @cocotb.test()
# @report_test
# async def outel8227(dut):
#     memory = Memory()
#     memory.mem[8*int("0xFFFE",16) : 8*int("0xFFFE",16) + 7] = int("0xCA",16) #ADL of reset pointer
#     memory.mem[8*int("0xFFFF",16) : 8*int("0xFFFF",16) + 7] = int("0xCC",16) #ADH of reset Pointer
#     memory.mem[8*int("0xFFFC",16) : 8*int("0xFFFC",16) + 7] = int("0xDB",16) #ADL of reset pointer
#     memory.mem[8*int("0xFFFD",16) : 8*int("0xFFFD",16) + 7] = int("0xCC",16) #ADH of reset Pointer
#     memory.mem[8*int("0x0000",16) : 8*int("0x0000",16) + 7] = int("0b00000101",2) #first number to multiply
#     memory.mem[8*int("0x0001",16) : 8*int("0x0001",16) + 7] = int("0b00000111",2) #second number to multiply
#     memory.mem[8*int("0x0002",16) : 8*int("0x0002",16) + 7] = int("0x00",16) #result, less than 256 unsigned or 127 and greater than -128 signed
#     memory.mem[8*int("0xCCDB",16) : 8*int("0xCCDB",16) + 7] = int("0x58",16) #CLI
#     memory.mem[8*int("0xCCDC",16) : 8*int("0xCCDC",16) + 7] = int("0xA9",16) #LDA
#     memory.mem[8*int("0xCCDD",16) : 8*int("0xCCDD",16) + 7] = int("0x00",16) #data to load
#     memory.mem[8*int("0xCCDE",16) : 8*int("0xCCDE",16) + 7] = int("0xA2",16) #LDX
#     memory.mem[8*int("0xCCDF",16) : 8*int("0xCCDF",16) + 7] = int("0x00",16) #data to load
#     memory.mem[8*int("0xCCE0",16) : 8*int("0xCCE0",16) + 7] = int("0x18",16) #CLC
#     memory.mem[8*int("0xCCE1",16) : 8*int("0xCCE1",16) + 7] = int("0x65",16) #ADC
#     memory.mem[8*int("0xCCE2",16) : 8*int("0xCCE2",16) + 7] = int("0x00",16) #zpg ABL
#     memory.mem[8*int("0xCCE3",16) : 8*int("0xCCE3",16) + 7] = int("0xE8",16) #INX
#     memory.mem[8*int("0xCCE4",16) : 8*int("0xCCE4",16) + 7] = int("0xE4",16) #CPX
#     memory.mem[8*int("0xCCE5",16) : 8*int("0xCCE5",16) + 7] = int("0x01",16) #zpg ABL
#     memory.mem[8*int("0xCCE6",16) : 8*int("0xCCE6",16) + 7] = int("0xD0",16) #BNE
#     memory.mem[8*int("0xCCE7",16) : 8*int("0xCCE7",16) + 7] = int("0xF8",16) #move 1111 1000 or -8
#     memory.mem[8*int("0xCCE8",16) : 8*int("0xCCE8",16) + 7] = int("0x8D",16) #STA
#     memory.mem[8*int("0xCCE9",16) : 8*int("0xCCE9",16) + 7] = int("0x02",16) #ABS ABL
#     memory.mem[8*int("0xCCEA",16) : 8*int("0xCCEA",16) + 7] = int("0x00",16) #ABS ABH

#     caravelEnv = await test_configure(dut, timeout_cycles=1346140)

#     cocotb.log.info(f"[TEST] Start outel8227 test")  
#     # wait for start of sending
#     caravelEnv.drive_gpio_in((37,0), 0x0)
#     await caravelEnv.release_csb()
#     await caravelEnv.wait_mgmt_gpio(1)
#     cocotb.log.info(f"[TEST] finish configuration") 

#     await caravelEnv.drive_gpio_in((34, 37), 0x1) # CHECK TO MAKE SURE ITS CORRECT
#     await cocotb.triggers.ClockCycles(caravelEnv.clk, 1)

from caravel_cocotb.caravel_interfaces import * # import python APIs
import cocotb

caravelEnv : Caravel_env = None
half_clk_period : int = 0

@cocotb.test() # cocotb test marker
@report_test # wrapper for configure test reporting files
async def outel8227(dut):
    global caravelEnv, half_clk_period
    cocotb.log.info("[7] Start configuration")
    testName = "Management"
    caravelEnv = await test_configure(dut, timeout_cycles=2000000)
    cocotb.log.info("[7] Await mgmt_gpio")

    # ensure to drive input pins BEFORE running firmware with release_csb()
    #1,2,3,4,20-27,29-37
    caravelEnv.drive_gpio_in((4,1), 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(20, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(21, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(22, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(23, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(24, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in((37, 30), 0xEA)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)


    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    cocotb.log.info("[7] Finish configuration")
    global half_clk_period
    half_clk_period = caravelEnv.get_clock_period() / 2
