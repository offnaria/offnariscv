// SPDX-License-Identifier: MIT

interface axis_if # (
  parameter TDATA_WIDTH = 32
);
  logic tvalid;
  logic tready;
  logic [TDATA_WIDTH-1:0] tdata;

  // Manager modport
  modport m (output tvalid, tdata, input tready);

  // Subordinate modport
  modport s (input tvalid, tdata, output tready);

  function automatic logic ack();
    return tvalid && tready;
  endfunction

endinterface
