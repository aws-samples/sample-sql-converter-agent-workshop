package com.example.service;

import com.example.dao.EmployeeDao;
import com.example.entity.Employee;
import com.example.dto.EmployeeSearchCriteria;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
@Transactional
public class EmployeeService {

    @Autowired
    private EmployeeDao employeeDao;

    @Transactional
    public Employee createEmployee(Employee employee) {
        // Oracle SEQUENCEから次のIDを取得
        Long nextId = employeeDao.getNextEmployeeId();
        employee.setEmployeeId(nextId);
        employee.setHireDate(LocalDateTime.now());
        employee.setCreatedAt(LocalDateTime.now());
        employee.setUpdatedAt(LocalDateTime.now());
        
        int result = employeeDao.insertEmployee(employee);
        if (result > 0) {
            return employeeDao.findById(nextId);
        }
        throw new RuntimeException("Failed to create employee");
    }

    @Transactional(readOnly = true)
    public Employee getEmployeeById(Long employeeId) {
        Employee employee = employeeDao.findById(employeeId);
        if (employee == null) {
            throw new RuntimeException("Employee not found: " + employeeId);
        }
        return employee;
    }

    @Transactional
    public Employee updateEmployee(Employee employee) {
        Employee existing = employeeDao.findById(employee.getEmployeeId());
        if (existing == null) {
            throw new RuntimeException("Employee not found: " + employee.getEmployeeId());
        }
        
        employee.setUpdatedAt(LocalDateTime.now());
        int result = employeeDao.updateEmployee(employee);
        if (result > 0) {
            return employeeDao.findById(employee.getEmployeeId());
        }
        throw new RuntimeException("Failed to update employee");
    }

    @Transactional
    public void deleteEmployee(Long employeeId) {
        Employee existing = employeeDao.findById(employeeId);
        if (existing == null) {
            throw new RuntimeException("Employee not found: " + employeeId);
        }
        
        int result = employeeDao.deleteEmployee(employeeId);
        if (result == 0) {
            throw new RuntimeException("Failed to delete employee");
        }
    }

    @Transactional(readOnly = true)
    public List<Employee> searchEmployees(EmployeeSearchCriteria criteria) {
        return employeeDao.findBySearchCriteria(criteria);
    }

    @Transactional(readOnly = true)
    public int countEmployees(EmployeeSearchCriteria criteria) {
        return employeeDao.countBySearchCriteria(criteria);
    }

    @Transactional(readOnly = true)
    public List<Employee> getTopEarnersByDepartment(Long departmentId, int page, int size) {
        int startRow = (page - 1) * size + 1;
        int endRow = page * size;
        return employeeDao.findTopEarnersByDepartment(departmentId, startRow, endRow);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getDepartmentStatistics(int minEmployeeCount) {
        return employeeDao.getDepartmentStatistics(minEmployeeCount);
    }

    @Transactional
    public int increaseSalaryByDepartmentAndJob(Long departmentId, String jobId, Double increaseRate) {
        if (increaseRate <= 0 || increaseRate > 2.0) {
            throw new IllegalArgumentException("Increase rate must be between 0 and 2.0");
        }
        return employeeDao.bulkUpdateSalary(departmentId, jobId, increaseRate);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getEmployeeHierarchy() {
        return employeeDao.getEmployeeHierarchy();
    }
}
