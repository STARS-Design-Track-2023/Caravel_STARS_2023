from caravel_cocotb.caravel_interfaces import * # import python APIs
import cocotb

# MMIO_START_ADDR                 = 0xff00 #Memory Mapped IO
# GPIO_CONTROL_OFFSET             = 0x80,
# GPIO_ACCESS_OFFSET              = 0x90,
# SS_ACCESS_OFFSET                = 0xa0,
# INPUT_HANDLER_ACCESS_OFFSET     = 0xb0,
# GPIO_INTERRUPT_MASK_OFFSET      = 0xc0,
# TIMER_OFFSET                    = 0xd0

# GPIO_CONTROL_START_ADDR         = MMIO_START_ADDR + 0x80
# GPIO_CONTROL_END_ADDR           = (GPIO_CONTROL_START_ADDR + GPIO_CONTROL_SIZE - 1)
# GPIO_ACCESS_START_ADDR          = (MMIO_START_ADDR + 0xb000 + GPIO_ACCESS_OFFSET)
# GPIO_ACCESS_END_ADDR            = (GPIO_ACCESS_START_ADDR + GPIO_ACCESS_SIZE - 1)
# SS_ACCESS_START_ADDR            = (MMIO_START_ADDR + 0xb000 + SS_ACCESS_OFFSET)
# SS_ACCESS_END_ADDR              = (SS_ACCESS_START_ADDR + SS_ACCESS_SIZE - 1)
# INPUT_HANDLER_ACCESS_START_ADDR = (MMIO_START_ADDR + 0xb000 + INPUT_HANDLER_ACCESS_OFFSET)
# INPUT_HANDLER_ACCESS_END_ADDR   = (INPUT_HANDLER_ACCESS_START_ADDR + INPUT_HANDLER_ACCESS_SIZE - 1)
# GPIO_INTERRUPT_MASK_START_ADDR  = (MMIO_START_ADDR + 0xb0 + GPIO_INTERRUPT_MASK_OFFSET)
# GPIO_INTERRUPT_MASK_END_ADDR    = (GPIO_INTERRUPT_MASK_START_ADDR + GPIO_INTERRUPT_MASK_SIZE - 1)
# TIMER_START_ADDR                = (MMIO_START_ADDR + 0xb000+ TIMER_OFFSET)
# TIMER_END_ADDR                  = (TIMER_START_ADDR + TIMER_SIZE - 1)


testName = "Start"
caravelEnv : Caravel_env = None
half_clk_period : int = 0

class pinMap:
    memory_data_in = (27, 20)         #Input
    programmable_gpio_in = (37, 30)   #Input
    interrupt_gpio_in = 29            #Input
    memory_address_out_h = (19, 5)    #Output
    memory_address_out_l = 0          #Output
    memory_data_out = (27, 20)        #Output
    programmable_gpio_out = (37, 30)  #Output
    memory_wr = 28                    #Output
    chip_select = (4, 1)
    #programmable_gpio_wr = 0          #Oeb, not an exeternal pin
    #Inputs: (20,27) & (29,37) & (0,3)
    #1,2,3,4,20-27,29-37

class address_types:
    addr_is_gpio_control = 0
    addr_is_gpio_pin = 1
    addr_is_ss = 2
    addr_is_input_handler = 3
    addr_is_gpio_interrupt_mask = 4 
    addr_is_timer = 5
    addr_gpio_is_read = 6

# async def DetermineAddressType(address):
#     global MMIO_START_ADDR, GPIO_CONTROL_OFFSET, GPIO_ACCESS_OFFSET, SS_ACCESS_OFFSET, \
#             INPUT_HANDLER_ACCESS_OFFSET, GPIO_INTERRUPT_MASK_OFFSET, TIMER_OFFSET, \
#             GPIO_CONTROL_START_ADDR, GPIO_CONTROL_END_ADDR, GPIO_ACCESS_START_ADDR, \
#             GPIO_ACCESS_END_ADDR, SS_ACCESS_START_ADDR, SS_ACCESS_END_ADDR, \
#             INPUT_HANDLER_ACCESS_START_ADDR, INPUT_HANDLER_ACCESS_END_ADDR, \
#             GPIO_INTERRUPT_MASK_START_ADDR, GPIO_INTERRUPT_MASK_END_ADDR, \
#             TIMER_START_ADDR, TIMER_END_ADDR, \
#             address_types #also include this class
#     #---------------------------------------------------------------------------------

#     if (address >= GPIO_CONTROL_START_ADDR and address <= GPIO_CONTROL_END_ADDR):
#         return address_types.addr_is_gpio_control

#     if(address >= GPIO_ACCESS_START_ADDR and address <= GPIO_ACCESS_END_ADDR):
#         return address_types.addr_is_gpio_pin
    
#     if(address >= SS_ACCESS_START_ADDR and address <= SS_ACCESS_END_ADDR):
#         return address_types.addr_is_ss

#     if(address >= INPUT_HANDLER_ACCESS_START_ADDR and address <= INPUT_HANDLER_ACCESS_END_ADDR):
#         return address_types.addr_is_input_handler

#     if(address >= GPIO_INTERRUPT_MASK_START_ADDR and address <= GPIO_INTERRUPT_MASK_END_ADDR):
#         return address_types.addr_is_gpio_interrupt_mask

#     if(address >= TIMER_START_ADDR and address <= TIMER_END_ADDR):
#         return address_types.addr_is_timer

#     #The order of this last one might need to be shifted
#     if(True):#addr_gpio_is_read = ~programmable_gpio_wr[address[2:0]];
#         return address_types.addr_gpio_is_read

@cocotb.test() # cocotb test marker
@report_test # wrapper for configure test reporting files
async def Geriatrics(dut):
    global address_types, caravelEnv
    cocotb.log.info("[4] Start configuration")
    testName = "Management"
    caravelEnv = await test_configure(dut, timeout_cycles=2000000)
    cocotb.log.info("[4] Await mgmt_gpio")

    # ensure to drive input pins BEFORE running firmware with release_csb()
    #1,2,3,4,20-27,29-37
    caravelEnv.drive_gpio_in(1, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(2, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(3, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(4, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(20, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(21, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(22, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(23, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(24, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(25, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(26, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(27, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(29, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(30, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(31, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(32, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(33, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(34, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(35, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(36, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    caravelEnv.drive_gpio_in(37, 0x0)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    


    # caravelEnv.drive_gpio_in(pinMap.chip_select, 0xF)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    # caravelEnv.drive_gpio_in(pinMap.interrupt_gpio_in, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    # caravelEnv.drive_gpio_in(pinMap.memory_data_in, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    # caravelEnv.drive_gpio_in(pinMap.programmable_gpio_in, 0xFF)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)

    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    cocotb.log.info("[4] Finish configuration")
    global half_clk_period
    half_clk_period = caravelEnv.get_clock_period() / 2

    testName = "Test1"
    cocotb.log.info(f"[4] T1: Power-on-reset")
    # "reset" design
    # caravelEnv.drive_gpio_in(pinMap.chip_select, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    # caravelEnv.drive_gpio_in(pinMap.interrupt_gpio_in, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    # caravelEnv.drive_gpio_in(pinMap.memory_data_in, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    # caravelEnv.drive_gpio_in(pinMap.programmable_gpio_in, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)

    testName = "Test 2"
    cocotb.log.info(f"[4] T2: Register Loading And Reading")
    # "reset" design
    # caravelEnv.drive_gpio_in(pinMap.chip_select, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    # caravelEnv.drive_gpio_in(pinMap.interrupt_gpio_in, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    # caravelEnv.drive_gpio_in(pinMap.memory_data_in, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    # caravelEnv.drive_gpio_in(pinMap.programmable_gpio_in, 0x1)  # ONLY DRIVE TO INPUT/UNUSED PINS (NOT OUTPUTS!)
    # wait 2 clk cycles
    await cocotb.triggers.ClockCycles(caravelEnv.clk,2)
    await cocotb.triggers.Timer(half_clk_period, 'ns')

    #control unit starts in fetch_state 
    #It initially reads from 0x2000
    #op code, and immediate? are all 0
    #program counter goes to 0x1000
    #registers initialize to zero
    #?SP initializes to 16'hff00

    #Send Op Code
    #Set mem_data_in to 8'b0, opcode (16 bits total)

    #Send_imm_byte
    #write data for a clock cycle

    #Send double byte
    #It looks like it grabs a single byte from the db, shifts it to the top of a register, then fills the bottom portion

    #OP CODES
    #lda, 8'h11:        8'h3E -> 8'h11 set reg a to 8'h11 (2 clock cycles)
    #call 16'h1234      8'hCD -> 8'h34 -> 8'h12 set PC to 16'h1234, decrease stack pointer
    #jp 16'h1234        8'hC3 -> 8'h34 -> 8'h12 set PC to 16'h1234
    #ret                8'hC9 -> 8'h34 -> 8'h12 set PC to the top two bytes of the stack, SP+=2
    #ld bc, 0x1234 and push bc
    #pop bc
    #bit 7, b
    #set 7, b
    #res 7, b
    #djnz 0xff (updates PC)
    #djnz 0x32 (does not update PC)

    #Test: Load the accumulator with a value, repeat with another register, retreive the value of the first
    #Coverage:

    #How do I do this?
    #I know that I have to send the opcode 3E at some point
    #I also have to send 11 afterwards.  This is probably 1 clock cycle later

    #How does the memory know to send in 3E?
    #Is 3E stored at the first location in memory

    #What controls memory_addr_out
    #control unit drives mem_addr which is filtered by read_write before bubbling up
    #Memory acknowledge must pulse high for 1 clock cycle in the cycle to read memory. otherwise it keeps waiting

    #What happens with data
    #send signal, idx is set to zero, then it is incremented when acknowledge goes high, then next byte will be read...
    #TAKEAWAY: data is set, then on the first clock cycle where acknowledge is high, data read

    #16 bit data Input bus: memory_data_in.  IR uses the lower 8 bits

    #1: Read memory_address_out (display value and confirm)
    testName = "Read"
    gpio_value_h = caravelEnv.monitor_gpio(pinMap.memory_address_out_h).integer
    gpio_value_l = caravelEnv.monitor_gpio(pinMap.memory_address_out_h).integer
    memoryAddress = gpio_value_h*2+gpio_value_l
    cocotb.log.info(f"Initial memory_address_out: {hex(memoryAddress)}")
    #2: Wait X clock cycles
    #3: Place 3E on memory_data_in
    #4: Wait 2 clock cycles
    #5: Acknowledge memory for 1 clock cycle

    #6: 