// SPDX-License-Identifier: MIT

package cache_pkg;

  typedef struct packed {
    logic v;  // Valid bit
    logic d;  // Dirty bit
    logic u;  // Unique bit
  } line_state_t; // NOTE: With these 3 bits, the cache controller can use almost all typical cache coherence protocols

  function logic is_modified(line_state_t state);
    return state.v && state.d && state.u;  // UniqueDirty
  endfunction

  function logic is_owned(line_state_t state);
    return state.v && state.d && !state.u;  // SharedDirty
  endfunction

  function logic is_exclusive(line_state_t state);
    return state.v && !state.d && state.u;  // UniqueClean
  endfunction

  function logic is_shared(line_state_t state);
    return state.v && !state.d && !state.u;  // SharedClean
  endfunction

  function logic is_invalid(line_state_t state);
    return !state.v;  // Invalid
  endfunction

endpackage
