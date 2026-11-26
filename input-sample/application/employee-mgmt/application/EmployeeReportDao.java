package com.example.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.sql.DataSource;

/**
 * 社員のレポート（JDBC）。
 * 画面で指定された検索条件に応じて、SQL を文字列の連結で組み立てて実行する。
 */
public class EmployeeReportDao {

    private final DataSource dataSource;

    public EmployeeReportDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    /**
     * 条件に合う社員を、指定した並び順で先頭から maxRows 件返す。
     * 条件は、指定されたもの（null でないもの）だけを WHERE 句に加える。
     */
    public List<Map<String, Object>> searchEmployees(String lastNamePrefix, Integer departmentId,
            Double minSalary, String sortKey, int maxRows) throws SQLException {
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        sql.append("SELECT * FROM (");
        sql.append(" SELECT e.employee_id, e.first_name || ' ' || e.last_name AS full_name,");
        sql.append("        NVL(d.department_name, 'No Department') AS department_name,");
        sql.append("        DECODE(e.commission_pct, NULL, 'N', 'Y') AS has_commission,");
        sql.append("        TO_CHAR(e.hire_date, 'YYYY-MM-DD') AS hire_date");
        sql.append(" FROM employees e, departments d");
        sql.append(" WHERE e.department_id = d.department_id(+)");
        if (lastNamePrefix != null && !lastNamePrefix.isEmpty()) {
            sql.append(" AND UPPER(e.last_name) LIKE UPPER(?) || '%'");
            params.add(lastNamePrefix);
        }
        if (departmentId != null) {
            sql.append(" AND e.department_id = ?");
            params.add(departmentId);
        }
        if (minSalary != null) {
            sql.append(" AND NVL(e.salary, 0) >= ?");
            params.add(minSalary);
        }
        if ("salary".equals(sortKey)) {
            sql.append(" ORDER BY NVL(e.salary, 0) DESC, e.employee_id");
        } else if ("hireDate".equals(sortKey)) {
            sql.append(" ORDER BY e.hire_date, e.employee_id");
        } else {
            sql.append(" ORDER BY e.employee_id");
        }
        sql.append(" ) WHERE ROWNUM <= ?");
        params.add(maxRows);
        return query(sql.toString(), params);
    }

    /**
     * 部署ごとの人数と平均給与を返す。
     * includeEmptyDepartments が true のときは、社員のいない部署も含める。
     */
    public List<Map<String, Object>> summarizeByDepartment(boolean includeEmptyDepartments)
            throws SQLException {
        String sql = "SELECT d.department_id, d.department_name,"
                + " COUNT(e.employee_id) AS headcount,"
                + " NVL(ROUND(AVG(e.salary), 2), 0) AS avg_salary";
        sql += " FROM departments d, employees e";
        if (includeEmptyDepartments) {
            sql += " WHERE d.department_id = e.department_id(+)";
        } else {
            sql += " WHERE d.department_id = e.department_id";
        }
        sql += " GROUP BY d.department_id, d.department_name";
        sql += " ORDER BY d.department_id";
        return query(sql, new ArrayList<>());
    }

    private List<Map<String, Object>> query(String sql, List<Object> params) throws SQLException {
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData md = rs.getMetaData();
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    for (int c = 1; c <= md.getColumnCount(); c++) {
                        row.put(md.getColumnLabel(c), rs.getObject(c));
                    }
                    rows.add(row);
                }
                return rows;
            }
        }
    }
}
