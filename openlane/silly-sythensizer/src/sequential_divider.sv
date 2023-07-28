module sequential_divider(input logic clk, nrst, sample_now,
                            input logic [17:0] divisor, input logic [17:0] oscillator_out,
                            output logic [7:0] q_out);
logic [4:0] count, next_count;
logic start, next_start, div, next_div;
logic [26:0] a_part1, q, next_q, q_part1, a, next_a, next_m, m;
logic [7:0] next_out;
logic change_out;

always_comb begin
    if(sample_now) begin
        next_a = 0;
        next_m = {1'b0, 8'b0, divisor};
        next_q = {1'b0, oscillator_out, 8'b0};
        next_count = 0;
        a_part1 = 0;
        q_part1 = 0;
       
        next_start = 1;
        next_div = 0;

        next_out = q[7:0];
        change_out = 0;
    end
    else if(count < (27) & (start)) begin
        {a_part1, q_part1} = {a, q} << 1;
        next_m = m;

        if(a_part1[26] == 1'b1) begin
            next_a = a_part1 + m;
        end
        else begin
            next_a = a_part1 - m;
        end

        if(next_a[26] == 1'b1) begin
            next_q = q_part1;
        end
        else begin
            next_q = q_part1 + 1;
        end

        next_count = count + 1;

        next_start = 1;
        next_div = 1;

        next_out = q[7:0];
        change_out = 0;

    end
    else if(div) begin
        next_q = q;
        q_part1 = 0;
        next_m = m;
        next_a = a;
        a_part1 = 0;
        next_count = count;

        next_start = 0;
        next_div = 0;

        next_out = q[7:0];
        change_out = 1;
        if(q[8:0] == 9'b100000000)
            next_out = 8'hff;

    end
    else begin
        
        next_q = q;
        q_part1 = 0;
        next_m = m;
        next_a = a;
        a_part1 = 0;
        next_count = count;

        next_start = 0;
        next_div = 0;

        next_out = q[7:0];
        change_out = 0;
    end
end

always_ff @(posedge clk, negedge nrst) begin
    if(!nrst) begin
        count <= 0;
        q <= 0;
        m <= 0;
        a <= 0;

        start <= 0;
        div <= 0;
    end else begin
        count <= next_count;
        q <= next_q;
        m <= next_m;
        a <= next_a;

        start <= next_start;
        div <= next_div;
    end
end

always_ff @ (posedge clk, negedge nrst) begin
    if(!nrst)
        q_out <= 0;
    else if(change_out)
        q_out <= next_out;
end
endmodule