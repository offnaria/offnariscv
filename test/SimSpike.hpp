// SPDX-License-Identifier: MIT

#include "sim.h"

class SimSpike : public sim_t {
 public:
  using sim_t::sim_t;
  void start_htif();
  void stop_htif();
};
