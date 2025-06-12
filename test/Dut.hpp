// SPDX-License-Identifier: MIT

template <class T>
class Dut {
    T* dut_wrap;
public:
    Dut() {
        dut_wrap = new T();
    }
    ~Dut() {
        dut_wrap->final();
        delete dut_wrap;
    }

    T* operator->() const noexcept {
        return dut_wrap;
    }
    void step(int n = 1) {
        for (int i = 0; i < n; i++) {
            dut_wrap->clk = 0;
            dut_wrap->eval();
            dut_wrap->clk = 1;
            dut_wrap->eval();
        }
    }
    void reset(int n = 10) {
        dut_wrap->rst = 1;
        step(n);
        dut_wrap->rst = 0;
    }
};
