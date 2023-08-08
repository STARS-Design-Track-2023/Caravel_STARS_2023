module timer (input logic clk, input logic nrst, input logic enable_dec, input logic enable_in, input logic clk_div, input logic lap, input logic clear, output logic time_up, output logic [11:0] timer_out);

  logic [11:0] count_next, cnt, dummy;
  logic next_time_up;
  always_ff @ (posedge clk, negedge nrst) begin
    if (!nrst) begin
      cnt <= 0;
      time_up <= 0;
    end 
    else begin
      cnt <= count_next;
      time_up <= next_time_up;
    end
  end

  always_comb begin
    count_next = cnt;
    next_time_up = time_up;

    if (clear) begin
        count_next = 0;
        next_time_up = 0;
    end
    else if (enable_dec) begin
      if (enable_dec && (cnt == 0))
        next_time_up = 1;
      else begin
        if(cnt[5:0] > 0) begin
            count_next[5:0] = cnt[5:0] - {5'b0, clk_div};
        end
        else if (clk_div)begin
            count_next[11:6] = cnt[11:6] - 1;
            count_next[5:0] = 59;
        end 
        else 
            count_next = cnt;
      end 
    end
    else if (enable_in) begin
      if (lap)
        
        if(cnt[5:0] >= 30) begin 
            count_next[5:0] = 0;
            count_next[11:6] = cnt[11:6] + 1;
        end 

        else 
          count_next[5:0] = cnt[5:0] + 30;

    
    end
    timer_out = cnt;
  end 

endmodule
