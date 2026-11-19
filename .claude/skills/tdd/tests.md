---
name: verify-behavior-not-implementation
description: Guidelines for writing robust, refactor-safe tests in Python and C++. Prioritizes testing observable behavior through public interfaces over mocking internal logic or checking implementation details.
---

# High-Signal Testing: Behavior vs. Implementation

## The Golden Rule
Test the **Contract**, not the **Code Path**. A good test should pass both before and after a complete internal refactor, provided the output remains the same.

---

## Good Tests (Observable Behavior)

Focus on the public API and the "Black Box" approach. These tests describe **WHAT** the system does for the caller.

### Python (pytest)
```python
# GOOD: Testing the observable outcome
def test_calculator_accumulates_total():
    calc = Calculator()
    calc.add(10)
    calc.add(5)
    assert calc.get_total() == 15  # Verifies state via public API
```

### C++ (gtest)
```c++
// GOOD: Focuses on the logical result of the operation
TEST(BankProfile, DepositIncrementsBalance) {
    Account account;
    account.Deposit(100.0);
    EXPECT_DOUBLE_EQ(account.GetBalance(), 100.0);
}
```

### Red Flags:

 - Mocks Everywhere: Mocking classes that are part of the same logical unit or module.

 - Strict Call Ordering: Asserting that function A was called before function B when the order doesn't affect the final result.

 - Leaky Abstractions: Reaching into an object to check its private members (e.g., using FRIEND_TEST in GTest too liberally).


### C++ redflag:
```c++
// BAD: Testing internal state that should not be exposed
TEST(DataBuffer, CheckInternalIndex) {
    DataBuffer buffer;
    buffer.Write("data");
    
    // Red Flag: Accessing internal pointers or private-ish state.
    // This prevents you from ever changing how the buffer stores data.
    EXPECT_EQ(buffer.internal_ptr_offset_, 4); 
}
```

### Python redflag:

```python
# BAD: Coupled to internal call structure
from unittest.mock import Mock

def test_process_order_calls_internal_sender():
    mailer = Mock()
    order_proc = OrderProcessor(mailer=mailer)
    order_proc.process({"id": 1})
    
    # Red Flag: Asserting that a specific internal method was called
    # If you rename 'send_raw_email_format', the test breaks even if mail still sends.
    mailer.send_raw_email_format.assert_called_once()
```
