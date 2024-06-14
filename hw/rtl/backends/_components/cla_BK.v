module cla_BK #(
    parameter NUM = 16
)(
    input  [NUM - 1:0] a,
    input  [NUM - 1:0] b,
    input              ci,
    output [NUM - 1:0] s,
    output             co
    );

localparam COUNT = $clog2(NUM);

wire [NUM - 1:0] p [COUNT * 2 - 1:0];
wire [NUM - 1:0] g [COUNT * 2 - 1:0];
assign p[0] = a ^ b;
assign g[0] = a & b;

genvar j;
genvar i;
generate
    for(j = 1; j < COUNT*2; j = j + 1) begin
        for(i = 0; i < NUM; i = i + 1) begin
            if(j <= COUNT && (i % 2 ** j) == ((2 ** j) - 1)) begin
                assign p[j][i] = p[j - 1][i - 2 ** (j - 1)] & p[j - 1][i];
                assign g[j][i] = g[j - 1][i] | g[j - 1][i - 2 ** (j - 1)] & p[j - 1][i];
            end
            else if(j > COUNT && i - (2 ** (COUNT * 2 - 1 - j)) > 0 && 
                    (i - (2 ** (COUNT * 2 - 1 - j))) % (2 ** (COUNT * 2 - j)) == (2 ** (COUNT * 2 - j)) - 1) begin
                assign p[j][i] = p[j - 1][i - (2 ** (COUNT * 2 - 1 - j))] & p[j - 1][i];
                assign g[j][i] = g[j - 1][i] | g[j - 1][i - (2 ** (COUNT * 2 - 1 - j))] & p[j - 1][i];
            end
            else begin
                assign p[j][i] = p[j - 1][i];
                assign g[j][i] = g[j - 1][i];
            end
        end
    end
endgenerate


wire [NUM - 1:0] c;
assign c = g[COUNT * 2 - 1] | p[COUNT * 2 - 1] & {NUM{ci}};
assign s = a ^ b ^ {c[NUM - 2:0], ci};

assign co = c[NUM-1];

endmodule