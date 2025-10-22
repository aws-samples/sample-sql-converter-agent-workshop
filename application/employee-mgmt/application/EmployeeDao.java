package com.example.dao;

import com.example.entity.Employee;
import com.example.dto.EmployeeSearchCriteria;
import org.apache.ibatis.annotations.*;
import java.util.List;
import java.util.Map;

@Mapper
public interface EmployeeDao {
    
    @Select("SELECT employee_seq.NEXTVAL FROM DUAL")
    Long getNextEmployeeId();
    
    @Insert({
        "INSERT INTO employees (",
        "  employee_id, first_name, last_name, email, phone_number,",
        "  hire_date, job_id, salary, commission_pct, manager_id,",
        "  department_id, created_at, updated_at",
        ") VALUES (",
        "  #{employeeId}, #{firstName}, #{lastName}, #{email}, #{phoneNumber},",
        "  #{hireDate}, #{jobId}, #{salary}, #{commissionPct}, #{managerId},",
        "  #{departmentId}, SYSDATE, SYSDATE",
        ")"
    })
    int insertEmployee(Employee employee);
    
    @Select({
        "SELECT e.*, d.department_name,",
        "       m.first_name || ' ' || m.last_name as manager_name",
        "FROM employees e",
        "LEFT JOIN departments d ON e.department_id = d.department_id",
        "LEFT JOIN employees m ON e.manager_id = m.employee_id",
        "WHERE e.employee_id = #{employeeId}"
    })
    Employee findById(Long employeeId);
    
    @Update({
        "UPDATE employees SET",
        "  first_name = #{firstName},",
        "  last_name = #{lastName},",
        "  email = #{email},",
        "  phone_number = #{phoneNumber},",
        "  job_id = #{jobId},",
        "  salary = #{salary},",
        "  commission_pct = #{commissionPct},",
        "  manager_id = #{managerId},",
        "  department_id = #{departmentId},",
        "  updated_at = SYSDATE",
        "WHERE employee_id = #{employeeId}"
    })
    int updateEmployee(Employee employee);
    
    @Delete("DELETE FROM employees WHERE employee_id = #{employeeId}")
    int deleteEmployee(Long employeeId);
    
    List<Employee> findBySearchCriteria(EmployeeSearchCriteria criteria);
    
    int countBySearchCriteria(EmployeeSearchCriteria criteria);
    
    @Select({
        "SELECT * FROM (",
        "  SELECT e.*, d.department_name,",
        "         m.first_name || ' ' || m.last_name as manager_name,",
        "         ROWNUM as rn",
        "  FROM employees e",
        "  LEFT JOIN departments d ON e.department_id = d.department_id",
        "  LEFT JOIN employees m ON e.manager_id = m.employee_id",
        "  WHERE e.department_id = #{departmentId}",
        "  ORDER BY e.salary DESC",
        ") WHERE rn BETWEEN #{startRow} AND #{endRow}"
    })
    List<Employee> findTopEarnersByDepartment(@Param("departmentId") Long departmentId,
                                            @Param("startRow") int startRow,
                                            @Param("endRow") int endRow);
    
    @Select({
        "SELECT d.department_name,",
        "       COUNT(*) as employee_count,",
        "       AVG(e.salary) as avg_salary,",
        "       MAX(e.salary) as max_salary,",
        "       MIN(e.salary) as min_salary",
        "FROM employees e",
        "JOIN departments d ON e.department_id = d.department_id",
        "GROUP BY d.department_id, d.department_name",
        "HAVING COUNT(*) > #{minEmployeeCount}",
        "ORDER BY avg_salary DESC"
    })
    List<Map<String, Object>> getDepartmentStatistics(@Param("minEmployeeCount") int minEmployeeCount);
    
    @Update({
        "UPDATE employees",
        "SET salary = salary * #{increaseRate},",
        "    updated_at = SYSDATE",
        "WHERE department_id = #{departmentId}",
        "  AND job_id = #{jobId}"
    })
    int bulkUpdateSalary(@Param("departmentId") Long departmentId,
                        @Param("jobId") String jobId,
                        @Param("increaseRate") Double increaseRate);
    
    @Select({
        "SELECT LEVEL as hierarchy_level,",
        "       employee_id,",
        "       first_name || ' ' || last_name as full_name,",
        "       job_id,",
        "       salary",
        "FROM employees",
        "START WITH manager_id IS NULL",
        "CONNECT BY PRIOR employee_id = manager_id",
        "ORDER SIBLINGS BY last_name, first_name"
    })
    List<Map<String, Object>> getEmployeeHierarchy();
}
