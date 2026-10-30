# Employee Management System - アーキテクチャドキュメント

## システム概要

Spring + MyBatisを使用した従業員管理システムのアーキテクチャ図です。

## クラス図

```mermaid
classDiagram
    class Employee {
        -Long employeeId
        -String firstName
        -String lastName
        -String email
        -String phoneNumber
        -LocalDateTime hireDate
        -String jobId
        -BigDecimal salary
        -BigDecimal commissionPct
        -Long managerId
        -Long departmentId
        -LocalDateTime createdAt
        -LocalDateTime updatedAt
        -String departmentName
        -String managerName
        +Employee()
        +Employee(firstName, lastName, email, jobId, salary)
        +getters/setters()
    }

    class EmployeeSearchCriteria {
        -String firstName
        -String lastName
        -String email
        -List~String~ jobIds
        -BigDecimal minSalary
        -BigDecimal maxSalary
        -Long departmentId
        -LocalDateTime hireDateFrom
        -LocalDateTime hireDateTo
        -String sortBy
        -String sortOrder
        -Integer offset
        -Integer limit
        +getters/setters()
    }

    class EmployeeDao {
        <<interface>>
        +getNextEmployeeId() Long
        +insertEmployee(Employee) int
        +findById(Long) Employee
        +updateEmployee(Employee) int
        +deleteEmployee(Long) int
        +findBySearchCriteria(EmployeeSearchCriteria) List~Employee~
        +countBySearchCriteria(EmployeeSearchCriteria) int
        +findTopEarnersByDepartment(Long, int, int) List~Employee~
        +getDepartmentStatistics(int) List~Map~
        +bulkUpdateSalary(Long, String, Double) int
        +getEmployeeHierarchy() List~Map~
    }

    class EmployeeService {
        -EmployeeDao employeeDao
        +createEmployee(Employee) Employee
        +getEmployeeById(Long) Employee
        +updateEmployee(Employee) Employee
        +deleteEmployee(Long) void
        +searchEmployees(EmployeeSearchCriteria) List~Employee~
        +countEmployees(EmployeeSearchCriteria) int
        +getTopEarnersByDepartment(Long, int, int) List~Employee~
        +getDepartmentStatistics(int) List~Map~
        +increaseSalaryByDepartmentAndJob(Long, String, Double) int
        +getEmployeeHierarchy() List~Map~
    }

    EmployeeService --> EmployeeDao : uses
    EmployeeService --> Employee : manages
    EmployeeService --> EmployeeSearchCriteria : uses
    EmployeeDao --> Employee : returns
    EmployeeDao --> EmployeeSearchCriteria : uses
```

## シーケンス図

### 従業員作成処理

```mermaid
sequenceDiagram
    participant Client
    participant EmployeeService
    participant EmployeeDao
    participant Database

    Client->>EmployeeService: createEmployee(employee)
    activate EmployeeService
    
    EmployeeService->>EmployeeDao: getNextEmployeeId()
    activate EmployeeDao
    EmployeeDao->>Database: SELECT employee_seq.NEXTVAL FROM DUAL
    Database-->>EmployeeDao: nextId
    EmployeeDao-->>EmployeeService: nextId
    deactivate EmployeeDao
    
    EmployeeService->>EmployeeService: setEmployeeId(nextId)
    EmployeeService->>EmployeeService: setHireDate(now)
    EmployeeService->>EmployeeService: setCreatedAt(now)
    EmployeeService->>EmployeeService: setUpdatedAt(now)
    
    EmployeeService->>EmployeeDao: insertEmployee(employee)
    activate EmployeeDao
    EmployeeDao->>Database: INSERT INTO employees...
    Database-->>EmployeeDao: result
    EmployeeDao-->>EmployeeService: result
    deactivate EmployeeDao
    
    alt result > 0
        EmployeeService->>EmployeeDao: findById(nextId)
        activate EmployeeDao
        EmployeeDao->>Database: SELECT with JOIN...
        Database-->>EmployeeDao: employee
        EmployeeDao-->>EmployeeService: employee
        deactivate EmployeeDao
        EmployeeService-->>Client: employee
    else
        EmployeeService-->>Client: RuntimeException
    end
    
    deactivate EmployeeService
```

### 従業員検索処理

```mermaid
sequenceDiagram
    participant Client
    participant EmployeeService
    participant EmployeeDao
    participant Database

    Client->>EmployeeService: searchEmployees(criteria)
    activate EmployeeService
    
    EmployeeService->>EmployeeDao: findBySearchCriteria(criteria)
    activate EmployeeDao
    EmployeeDao->>Database: Dynamic SQL with conditions
    Database-->>EmployeeDao: List<Employee>
    EmployeeDao-->>EmployeeService: List<Employee>
    deactivate EmployeeDao
    
    EmployeeService-->>Client: List<Employee>
    deactivate EmployeeService
```

### 従業員更新処理

```mermaid
sequenceDiagram
    participant Client
    participant EmployeeService
    participant EmployeeDao
    participant Database

    Client->>EmployeeService: updateEmployee(employee)
    activate EmployeeService
    
    EmployeeService->>EmployeeDao: findById(employeeId)
    activate EmployeeDao
    EmployeeDao->>Database: SELECT...
    Database-->>EmployeeDao: existing
    EmployeeDao-->>EmployeeService: existing
    deactivate EmployeeDao
    
    alt existing != null
        EmployeeService->>EmployeeService: setUpdatedAt(now)
        EmployeeService->>EmployeeDao: updateEmployee(employee)
        activate EmployeeDao
        EmployeeDao->>Database: UPDATE employees...
        Database-->>EmployeeDao: result
        EmployeeDao-->>EmployeeService: result
        deactivate EmployeeDao
        
        alt result > 0
            EmployeeService->>EmployeeDao: findById(employeeId)
            activate EmployeeDao
            EmployeeDao->>Database: SELECT with JOIN...
            Database-->>EmployeeDao: updated employee
            EmployeeDao-->>EmployeeService: updated employee
            deactivate EmployeeDao
            EmployeeService-->>Client: updated employee
        else
            EmployeeService-->>Client: RuntimeException
        end
    else
        EmployeeService-->>Client: RuntimeException
    end
    
    deactivate EmployeeService
```

### 従業員削除処理

```mermaid
sequenceDiagram
    participant Client
    participant EmployeeService
    participant EmployeeDao
    participant Database

    Client->>EmployeeService: deleteEmployee(employeeId)
    activate EmployeeService
    
    EmployeeService->>EmployeeDao: findById(employeeId)
    activate EmployeeDao
    EmployeeDao->>Database: SELECT...
    Database-->>EmployeeDao: existing
    EmployeeDao-->>EmployeeService: existing
    deactivate EmployeeDao
    
    alt existing != null
        EmployeeService->>EmployeeDao: deleteEmployee(employeeId)
        activate EmployeeDao
        EmployeeDao->>Database: DELETE FROM employees...
        Database-->>EmployeeDao: result
        EmployeeDao-->>EmployeeService: result
        deactivate EmployeeDao
        
        alt result > 0
            EmployeeService-->>Client: success
        else
            EmployeeService-->>Client: RuntimeException
        end
    else
        EmployeeService-->>Client: RuntimeException
    end
    
    deactivate EmployeeService
```

## アーキテクチャの特徴

- **レイヤードアーキテクチャ**: Service層とDAO層の分離
- **MyBatis統合**: アノテーションベースのSQLマッピング
- **トランザクション管理**: Spring @Transactionalによる宣言的トランザクション
- **Oracle固有機能**: SEQUENCE、ROWNUM、階層クエリなどを使用
