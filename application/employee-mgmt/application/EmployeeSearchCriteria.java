package com.example.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class EmployeeSearchCriteria {
    private String firstName;
    private String lastName;
    private String email;
    private List<String> jobIds;
    private BigDecimal minSalary;
    private BigDecimal maxSalary;
    private Long departmentId;
    private LocalDateTime hireDateFrom;
    private LocalDateTime hireDateTo;
    private String sortBy;
    private String sortOrder;
    private Integer offset;
    private Integer limit;

    // Getters and Setters
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public List<String> getJobIds() { return jobIds; }
    public void setJobIds(List<String> jobIds) { this.jobIds = jobIds; }
    
    public BigDecimal getMinSalary() { return minSalary; }
    public void setMinSalary(BigDecimal minSalary) { this.minSalary = minSalary; }
    
    public BigDecimal getMaxSalary() { return maxSalary; }
    public void setMaxSalary(BigDecimal maxSalary) { this.maxSalary = maxSalary; }
    
    public Long getDepartmentId() { return departmentId; }
    public void setDepartmentId(Long departmentId) { this.departmentId = departmentId; }
    
    public LocalDateTime getHireDateFrom() { return hireDateFrom; }
    public void setHireDateFrom(LocalDateTime hireDateFrom) { this.hireDateFrom = hireDateFrom; }
    
    public LocalDateTime getHireDateTo() { return hireDateTo; }
    public void setHireDateTo(LocalDateTime hireDateTo) { this.hireDateTo = hireDateTo; }
    
    public String getSortBy() { return sortBy; }
    public void setSortBy(String sortBy) { this.sortBy = sortBy; }
    
    public String getSortOrder() { return sortOrder; }
    public void setSortOrder(String sortOrder) { this.sortOrder = sortOrder; }
    
    public Integer getOffset() { return offset; }
    public void setOffset(Integer offset) { this.offset = offset; }
    
    public Integer getLimit() { return limit; }
    public void setLimit(Integer limit) { this.limit = limit; }
}
