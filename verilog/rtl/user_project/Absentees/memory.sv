module memory (
  input logic clk, nrst, clear, 
  input logic [11:0] count, input logic read, input logic write, output logic [11:0] out);
  
  logic  [11:0] mem1, mem2, mem3, mem4, mem5;
  logic  [11:0] next_mem1, next_mem2, next_mem3, next_mem4, next_mem5;
  logic signed [2:0] addr, next_addr, raddr, next_raddr;
  logic [11:0] next_out;

  always_ff @ (posedge clk, negedge nrst) begin
    if (!nrst) begin
      addr <= -1;
      raddr <= -1;
      mem1 <= 'b0;
      mem2 <= 'b0;
      mem3 <= 'b0;
      mem4 <= 'b0;
      mem5 <= 'b0;

      //out <= 0;
    end
    else begin
      addr <= next_addr;
      mem1 <= next_mem1;
      mem2 <= next_mem2;
      mem3 <= next_mem3;
      mem4 <= next_mem4;
      mem5 <= next_mem5;
      raddr <= next_raddr;
    end
  end

  always_comb begin
    next_raddr = raddr;
    next_addr = addr;
    next_mem1 = mem1;
    next_mem2 = mem2;
    next_mem3 = mem3;
    next_mem4 = mem4;
    next_mem5 = mem5;

    if(clear) begin
    next_addr = 0;
    next_mem1 = 0;
    next_mem2 = 0;
    next_mem3 = 0;
    next_mem4 = 0;
    next_mem5 = 0;
    next_raddr = 0;

    end 

    if (write) begin
	    next_addr = addr + 1;
      next_raddr = raddr + 1;
      case(addr + 1)
      1: next_mem2 = count;
      2: next_mem3 = count;
      3: next_mem4 = count;
      4: next_mem5 = count;
      default: next_mem1 = count;
      endcase
    end
    if (read) begin
      if (raddr == -1) begin
        next_raddr = addr;
      end
      else begin
        next_raddr = raddr - 1;
      end
    end
    case(raddr + 1)
      1: out = mem2;
      2: out = mem3;
      3: out = mem4;
      4: out = mem5;
      default: out = mem1;
      endcase

  end 
endmodule
