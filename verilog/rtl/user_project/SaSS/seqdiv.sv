// ************************************************************************************************
// Sequential Divider module
//   inputs: count <- 19 bit value from oscilator should be smaller than dsor as it is * 256
//           dsor <- 19 bit value from frequence table
//           sample <- expects a pulse from sample counter to tell to sample every 255 ticks
//           clk
//           RST <- expects a ACTIVE LOW rst Signals
//   output: Q_out <- 8 bit quotient fed to waveshaper
//           done <- signals when value is ready to be read
//
//   Use: Multi the count input by 256 (8 bit shift) and divides it by dsor only when a sample 
//        signal has be asserted. When the divison has completed after (bit width of dividend)
//        clock cycles an 8 bit Quotent will be output with a done signal. The done signal
//        will be asserted for as long as the quotient is correct.
// ************************************************************************************************



module seqdiv 
(
  input logic [18:0] count, dsor,
  input logic sample, clk, RST,
  output logic [8:0] Q_out,
  output logic done,
  output logic [18:0] count_m, divisor_m
);
  logic [27:0] part1_A, part1_Q, next_Q, Q, next_M, M, next_A, A; 
  logic [5:0] next_C, C; //counter variables to determine how many clock cycles have passed
  logic start, next_start, dived, next_dived;
  logic [18:0] count_store, divisor_store;

  always_comb begin
    
    if(sample) begin
      next_A = 0;                  //A is used to store the result of adding or subtracting the divisor from the dividend
      next_M = {1'b0, 8'b0, dsor}; //divisor is loaded into M with a leading sign bit and 8 leading 0s
      next_Q = {1'b0,count, 8'b0}; //Count is loaded into Q (sharded dividend and quotent register) with a sign bit and following 0s to "multiply" by 256
      next_C = 0; 
      part1_A = 0;
      part1_Q = 0;
      done = 0;

      count_store = count;
      divisor_store = dsor;

      next_start = 1;               //tells the divider to start only when the sample signal has been asserted
      next_dived = 0;

      Q_out = 0;
    end
    else if(C < (28) & start) begin
      {part1_A, part1_Q} = {A, Q} << 1; //treats A and Q as one register and shifts left so MSB of Q moves into the LSB of A
      next_M = M;                       //Loops the divisor in its register to act as memory so divisor does not change during divison 

      if(part1_A[27]) begin             //checks the sign bit of the, 1 means A is negative
        next_A = part1_A + M;
      end
      else begin
        next_A = part1_A - M;
      end
      
      if(next_A[27]) begin              //checks the sign bit of A after the previous operation, negative means 0 is stored in the Quotient
        next_Q = part1_Q;
      end
      else begin
        next_Q = part1_Q + 1;
      end

      next_C = C + 1;                   //increment counter
      done = 0;

      next_start = 1;

      next_dived = 1; 

      Q_out = 0;

      count_store = count_m;
      divisor_store = divisor_m;
    end
    else if (dived) begin               //checks if a value has been previously divided (used to make sure done signal is not asserted on RST)
      done = 1; 
      next_Q = Q;
      part1_Q = 0;
      next_M = M;
      next_A = A;
      part1_A = 0;
      next_C = C;

      next_start = 0;
      next_dived = 0;   //was 1

      count_store = count_m;
      divisor_store = divisor_m;

      Q_out = Q[8:0];
    end
    else begin
      done = 0; 
      next_Q = Q;
      part1_Q = 0;
      next_M = M;
      next_A = A;
      part1_A = 0;
      next_C = C;

      next_start = 0;
      next_dived = 0;

      Q_out = Q[8:0];

      count_store = count_m;
      divisor_store = divisor_m;
    end
  end
  
  always_ff @(posedge clk, negedge RST) begin
    if(!RST) begin
      C <= 0;
      Q <= 0;
      M <= 0;
      A <= 0;

      start <= 0;
      dived <= 0;
    end
    else begin
      Q <= next_Q;
      M <= next_M;
      C <= next_C;
      A <= next_A;

      start <= next_start;
      dived <= next_dived;
    end
  end

  always_ff @(posedge clk, negedge RST) begin
    if(!RST) begin
      count_m <= 0;
      divisor_m <= 0;
    end
    else begin
      count_m <= count_store;
      divisor_m <= divisor_store;
    end
  end
endmodule



