# Code Review Reference Guide

## SOLID Principles Deep Dive

### 1. Single Responsibility Principle (SRP)
**Definition**: A class or module should have only one reason to change.

**Why**: Makes code easier to test, maintain, and extend. Reduces side effects of changes.

**Anti-Pattern**:
```python
class UserManager:
    def create_user(self, name, email):
        # User creation logic
        pass
    
    def send_email(self, email, message):
        # Email sending logic
        pass
    
    def log_activity(self, user_id, action):
        # Logging logic
        pass
```
**Reason to Change**: User creation logic, email logic, AND logging logic. Three responsibilities!

**Better Pattern**:
```python
class UserRepository:
    def create(self, name, email):
        pass

class EmailService:
    def send(self, email, message):
        pass

class ActivityLogger:
    def log(self, user_id, action):
        pass

class UserManager:
    def __init__(self, repo, email, logger):
        self.repo = repo
        self.email = email
        self.logger = logger
    
    def create_user(self, name, email):
        user = self.repo.create(name, email)
        self.email.send(email, "Welcome!")
        self.logger.log(user.id, "created")
```

---

### 2. Open/Closed Principle (OCP)
**Definition**: Software should be open for extension but closed for modification.

**Why**: Adding new features shouldn't break existing code. Reduces regression risks.

**Anti-Pattern**:
```python
class PaymentProcessor:
    def process(self, payment, method):
        if method == "credit_card":
            # Process credit card
            pass
        elif method == "paypal":
            # Process PayPal
            pass
        elif method == "stripe":
            # Process Stripe
            pass
        # Adding new method requires modifying this class
```

**Better Pattern** (Strategy Pattern):
```python
class PaymentMethod(ABC):
    @abstractmethod
    def process(self, payment):
        pass

class CreditCardProcessor(PaymentMethod):
    def process(self, payment):
        pass

class PayPalProcessor(PaymentMethod):
    def process(self, payment):
        pass

class PaymentProcessor:
    def __init__(self, method: PaymentMethod):
        self.method = method
    
    def process(self, payment):
        return self.method.process(payment)
    # Adding new payment method: just add new class, no modification needed
```

---

### 3. Liskov Substitution Principle (LSP)
**Definition**: Subtypes must be substitutable for their base types without breaking behavior.

**Why**: Ensures polymorphism works correctly. Prevents silent bugs from incompatible subclasses.

**Anti-Pattern**:
```python
class Bird:
    def fly(self):
        pass

class Penguin(Bird):
    def fly(self):
        raise Exception("Penguins cannot fly!")  # LSP violated
```

**Better Pattern**:
```python
class Bird(ABC):
    @abstractmethod
    def move(self):
        pass

class FlyingBird(Bird):
    def move(self):
        self.fly()

class SwimmingBird(Bird):
    def move(self):
        self.swim()

class Penguin(SwimmingBird):
    def swim(self):
        pass
```

---

### 4. Interface Segregation Principle (ISP)
**Definition**: Clients should depend on specific interfaces, not bloated ones.

**Why**: Prevents unnecessary coupling. Reduces implementation burden.

**Anti-Pattern**:
```python
class Worker(ABC):
    @abstractmethod
    def work(self): pass
    
    @abstractmethod
    def eat_lunch(self): pass

class Robot(Worker):
    def work(self):
        pass
    
    def eat_lunch(self):
        raise Exception("Robots don't eat!")  # Forced to implement
```

**Better Pattern**:
```python
class Workable(ABC):
    @abstractmethod
    def work(self): pass

class Eatable(ABC):
    @abstractmethod
    def eat_lunch(self): pass

class Human(Workable, Eatable):
    def work(self): pass
    def eat_lunch(self): pass

class Robot(Workable):
    def work(self): pass
```

---

### 5. Dependency Inversion Principle (DIP)
**Definition**: High-level modules should depend on abstractions, not low-level modules.

**Why**: Reduces coupling. Makes testing easier. Enables swapping implementations.

**Anti-Pattern**:
```python
class EmailService:
    def send(self, message):
        # Direct SMTP connection
        pass

class UserRegistration:
    def __init__(self):
        self.email = EmailService()  # Tight coupling
    
    def register(self, user):
        self.email.send("Welcome!")
```

**Better Pattern**:
```python
class NotificationService(ABC):
    @abstractmethod
    def notify(self, message): pass

class EmailService(NotificationService):
    def notify(self, message):
        pass

class SMSService(NotificationService):
    def notify(self, message):
        pass

class UserRegistration:
    def __init__(self, notifier: NotificationService):
        self.notifier = notifier  # Depend on abstraction
    
    def register(self, user):
        self.notifier.notify("Welcome!")
```

---

## Security Checklist

### Secrets & Credentials
- [ ] No hardcoded API keys, database passwords, or tokens
- [ ] Secrets stored in environment variables or secrets manager (AWS Secrets, HashiCorp Vault)
- [ ] `.env` files not committed to source control
- [ ] No sensitive data in logs or error messages
- [ ] Credentials rotated regularly

### Input Validation
- [ ] All user inputs validated and sanitized
- [ ] Whitelist approach: only allow known-good inputs
- [ ] Validate type, length, format, and range
- [ ] Server-side validation (never rely on client-side alone)

### Injection Attacks
- [ ] **SQL Injection**: Use parameterized queries, ORMs, or prepared statements
  ```python
  # ❌ Bad
  query = f"SELECT * FROM users WHERE email = '{user_email}'"
  
  # ✅ Good
  query = "SELECT * FROM users WHERE email = ?"
  cursor.execute(query, [user_email])
  ```
- [ ] **Command Injection**: Use safe APIs, avoid shell=True, no user input in shell commands
- [ ] **Template Injection**: Use auto-escaping template engines

### XSS (Cross-Site Scripting)
- [ ] Output HTML-escaped (use framework features: Django's `|safe`, React's default escaping)
- [ ] User-generated content sanitized before display
- [ ] Content Security Policy (CSP) headers set
- [ ] No dangerouslySetInnerHTML or equivalent patterns

### Authentication & Authorization
- [ ] Passwords hashed with strong algorithm (bcrypt, Argon2)
- [ ] Session tokens secure (HttpOnly, Secure, SameSite cookies)
- [ ] Authorization checks on every protected endpoint
- [ ] Least privilege: users only access what they need
- [ ] No authentication bypass logic

### Deserialization
- [ ] No deserialization of untrusted data (pickle in Python, unsafe Java serialization)
- [ ] Use safe formats: JSON, Protocol Buffers
- [ ] Validate structure before deserialization

### Cryptography
- [ ] Use vetted libraries (not homegrown crypto)
- [ ] Strong algorithms: AES-256, SHA-256, TLS 1.2+
- [ ] Random number generation uses cryptographically secure RNG
- [ ] No deprecated algorithms (MD5, SHA-1)

### Dependencies
- [ ] No known vulnerable package versions (use `npm audit`, `pip audit`, OWASP dependency checker)
- [ ] Dependencies regularly updated
- [ ] Third-party libraries from trusted sources

---

## Performance Checklist

### Algorithmic Complexity
- [ ] Avoid O(n²) or worse in hot paths
  - ❌ Nested loops without indexing
  - ✅ Hash lookups, indexed database queries
- [ ] Identify and benchmark slow operations before optimization
- [ ] Document algorithmic complexity for critical functions

### Database Performance
- [ ] Use database indexes on frequently queried columns
- [ ] Avoid N+1 queries (fetch related data in single query, use JOINs)
  ```python
  # ❌ Bad: N+1 problem
  orders = db.query(Order).all()
  for order in orders:
      customer = db.query(Customer).filter_by(id=order.customer_id).first()
  
  # ✅ Good: Single query with JOIN
  orders = db.query(Order).join(Customer).all()
  ```
- [ ] Paginate large result sets
- [ ] Use query profiling tools to identify slow queries
- [ ] Avoid SELECT * — fetch only needed columns

### Memory Management
- [ ] Avoid unnecessary object allocations in loops
- [ ] Don't load entire datasets into memory; stream where possible
- [ ] Clean up resources (file handles, connections) via context managers
- [ ] Profile for memory leaks in long-running processes

### Caching Strategy
- [ ] Cache frequently accessed, rarely-changed data
- [ ] Set appropriate TTL (time-to-live) for cache entries
- [ ] Invalidate cache when underlying data changes
- [ ] Cache hierarchy: process-level → distributed (Redis) → database
- [ ] Monitor cache hit ratios

### Concurrency
- [ ] Use async/await for I/O-bound operations (not CPU-bound)
- [ ] Avoid blocking calls in event loops
- [ ] Thread-safe access to shared state (locks, atomic operations)
- [ ] Connection pooling for databases and external services

### Benchmark Guidelines
| Operation | Typical Latency | Acceptable Range |
|-----------|-----------------|------------------|
| Memory access | ~1 ns | N/A |
| L1 cache miss | ~4 ns | N/A |
| L3 cache miss | ~40 ns | N/A |
| Main memory access | ~100 ns | N/A |
| Disk seek | ~10 ms | < 50 ms for most apps |
| Network round-trip | ~100 ms | < 500 ms for user-facing |
| Database query (simple) | ~10 ms | < 100 ms |
| API call (external) | ~100-500 ms | depends on context |

---

## Test Coverage Best Practices

### Happy Path
- Test the normal, expected flow
- Verify outputs are correct
- Ensure side effects occur (database updates, emails sent)

### Edge Cases & Boundaries
- **Null/Empty**: `null`, empty string, empty collection
- **Boundaries**: min/max values, off-by-one
- **Zero/Negative**: zero division, negative amounts
- **Concurrency**: race conditions if applicable

### Error Cases
- Invalid input types
- Missing required parameters
- Exceptional conditions (timeout, network failure)
- Verify proper error messages and codes

### Flaky Tests (to avoid)
- Tests with hardcoded timeouts (use shorter, deterministic waits)
- Tests that depend on exact execution order
- Tests that assert on implementation details
- Tests that don't clean up state between runs

### Example: Comprehensive Test
```python
class TestPaymentProcessor:
    def test_successful_payment(self):
        # Happy path
        processor = PaymentProcessor()
        result = processor.charge(50.00, "credit_card")
        assert result.success == True
    
    def test_negative_amount_rejected(self):
        # Edge case: negative amount
        processor = PaymentProcessor()
        with pytest.raises(ValueError, match="must be positive"):
            processor.charge(-50.00, "credit_card")
    
    def test_zero_amount_rejected(self):
        # Boundary case
        with pytest.raises(ValueError):
            processor.charge(0.00, "credit_card")
    
    def test_invalid_card_returns_error(self):
        # Error case
        processor = PaymentProcessor()
        result = processor.charge(50.00, "invalid_card")
        assert result.success == False
        assert "invalid" in result.error.lower()
    
    def test_large_amount(self):
        # Boundary case: maximum amount
        processor = PaymentProcessor()
        result = processor.charge(999999.99, "credit_card")
        assert result.success == True
```

---

## Anti-Patterns to Watch For

| Anti-Pattern | Risk | Fix |
|---|---|---|
| God Objects | Hard to test, maintain, violate SRP | Extract responsibilities |
| Feature Envy | Method uses too many external methods | Move logic closer to data |
| Long Methods | Hard to test, understand, debug | Extract smaller methods |
| Deep Nesting | Reduces readability | Early returns, guards |
| Magic Numbers | Unclear intent, maintenance burden | Use named constants |
| Duplicate Code | Bug fixes repeated; inconsistency | Extract shared logic |
| Technical Debt Markers | Future maintenance burden | Address TODO/FIXME items |

---

## Quick Reference: What to Look For

**By Severity:**
- **Critical**: Security, data loss, crashes, breaking changes
- **High**: Performance regression, architectural violation, significant debt
- **Medium**: Code style, missing edge case test, minor architecture issue
- **Low**: Naming, minor documentation, suggested improvements

**By Category:**
- **Code Quality**: Naming, function size, complexity, duplication
- **Architecture**: Structure, dependencies, patterns, layers
- **Security**: Credentials, validation, injection, auth, crypto
- **Performance**: Algorithms, queries, caching, memory
- **Tests**: Coverage, edge cases, flakiness, clarity
- **Documentation**: Completeness, accuracy, examples
