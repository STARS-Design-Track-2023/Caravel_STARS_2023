`default_nettype none
module hit_scanning_and_scoring(
  input logic clk, n_rst, pushed,
  input logic [2:0] mode,
  input logic [38:0] padded_notes,
  input logic [22:0] counter, lim,
  output logic [15:0] num_misses, num_hits, 
  output logic missed, good
);
  logic [2:0] next_acc, acc;
  logic [22:0] counts, next_count;
  logic [15:0] next_num_misses, next_num_hits;
  logic [15:0] add_hit, add_miss;
  logic [22:0] next_flash_counter_1, flash_counter_1, next_flash_counter_2, flash_counter_2;
  logic start_count, next_start_count, hit, next_hit, check, next_missed, next_good;


  negedge_det check_hit(.clk(clk), .n_rst(n_rst), .in(start_count), .neg_edge(check)); //check if note was hit or missed

  always_ff @ (posedge clk, negedge n_rst) begin
    if (~n_rst) begin
      counts <= 0;
      hit <= 0;
      start_count <= 0;
      num_misses <= 0;
      num_hits <= 0;
      acc <= 1;
      good <= 0;
      missed <= 0;
      flash_counter_1 <= 0;
      flash_counter_2 <= 0;
    end
    else begin
      acc <= next_acc;
      counts <= next_count;
      hit <= next_hit;
      start_count <= next_start_count;
      num_misses <= next_num_misses;
      num_hits <= next_num_hits;
      good <= next_good;
      missed <= next_missed;
      flash_counter_1 <= next_flash_counter_1;
      flash_counter_2 <= next_flash_counter_2;
    end
  end
    
  bcdaddsub4 addhit(.a(num_hits), .b({13'b0, acc}), .op(1'b0), .s(add_hit));
  bcdaddsub4 addmiss(.a(num_misses), .b(16'b1), .op(1'b0), .s(add_miss));



  always_comb begin
    next_num_misses = num_misses;
    next_num_hits = num_hits;
    next_hit = hit;
    next_acc = acc;
    next_good = good;
    next_missed = missed;
    next_flash_counter_2 = 0;
    next_flash_counter_1 = 0;
    

    if (mode == 3'd1) begin
      next_num_misses = 0;
      next_num_hits = 0;
    end

    if (good) begin
      if (flash_counter_1 == 1000000) begin
        next_flash_counter_1 = 0;
        next_good = 0;
      end
      else
        next_flash_counter_1 = flash_counter_1 + 1;
    end

    if (missed) begin
      if (flash_counter_2 == 1000000) begin
        next_flash_counter_2 = 0;
        next_missed = 0;
      end
      else
        next_flash_counter_2 = flash_counter_2 + 1;
    end
    /*
    if (padded_notes[37]) begin
      if (counter == lim - 10)
        next_start_count = 1'b1;
      else if (counter == 10)
        next_start_count = 1'b0;
      else
        next_start_count = start_count;
    end
    else if (counter == 10)
      next_start_count = 1'b0;
    else
      next_start_count = start_count;

    if (start_count) begin
      next_count = counts + 1;
      if (pushed)
        good = 1'b1;
    end
    else begin
      next_count = 0;
      if (pushed)
        missed = 1'b1;
    end
     
    if ((counts >= 1 && counts <= 3) || (counts >= 17 && counts <= 19)) begin
      if (pushed) begin
        next_hit = 1'b1;
        next_acc = 1;
      end
    end
    else if ((counts >= 4 && counts <= 6) || (counts >= 14 && counts <= 16)) begin
      if (pushed) begin
        next_hit = 1'b1;
        next_acc = 2;
      end
    end
    else if ((counts >= 7 && counts <= 13)) begin
      if (pushed) begin
        next_hit = 1'b1;
        next_acc = 3;
      end
    end 
    else begin
      if (pushed) begin
        next_num_misses = num_misses + 1;
      end
      else begin
        next_num_misses = num_misses;
      end
      next_hit = hit;
    end */
    /*
    if (padded_notes[37]) begin
      if (counter == lim - 10)
        next_start_count = 1'b1;
      else if (counter == 10)
        next_start_count = 1'b0;
      else
        next_start_count = start_count;
    end
    else if (counter == 10)
      next_start_count = 1'b0;
    else
      next_start_count = start_count;
*/
    if (padded_notes[37]) begin
      if (counter == lim - 23'd1100000)
        next_start_count = 1'b1;
      else if (counter == 23'd1100000)
        next_start_count = 1'b0;
      else
        next_start_count = start_count;
    end
    else if (counter == 1100000)
      next_start_count = 1'b0;
    else
      next_start_count = start_count;

    if (start_count) begin
      next_count = counter + 1;
      if (pushed)
        next_good = 1'b1;
    end
    else begin
      next_count = 0;
      if (pushed)
        next_missed = 1'b1;
    end

    if ((counts >= 1 && counts <= 6000000) || (counts >= 1600000 && counts <= 2200000)) begin
      if (pushed) begin
        next_hit = 1'b1;
        next_acc = 3;
      end
    end
    else if ((counts >= 600001 && counts <= 900000) || (counts >= 1300000 && counts <= 159999)) begin
      if (pushed) begin
        next_hit = 1'b1;
        next_acc = 5;
      end
    end
    else if ((counts >= 900001) && (counts <= 1299999)) begin
      if (pushed) begin
        next_hit = 1'b1;
        next_acc = 7;
      end
    end 
    else if (pushed) begin
        next_num_misses = num_misses + 1;
    end
   
    if (check) begin
      next_hit = 1'b0;
      if(hit)
        next_num_hits = add_hit;
      else
        next_num_misses = add_miss;
    end
   
  end

endmodule