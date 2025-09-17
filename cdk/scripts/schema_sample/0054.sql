-- テーブルの作成
CREATE TABLE T_0054 (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    VALUE NUMBER,
    CREATED_DATE DATE DEFAULT SYSDATE
);

-- 1. 修正したJavaソースコード
CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED "SCT_0054_JavaSource" AS
import java.sql.*;

public class SCT_0054_JavaProc {
    // 単純な文字列を返すメソッド
    public static String getGreeting() {
        return "Hello from Java Stored Procedure!";
    }

    // テーブルから名前を取得するメソッド
    public static String getTableName(int id) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String result = "Not Found";

        try {
            conn = DriverManager.getConnection("jdbc:default:connection:");
            pstmt = conn.prepareStatement("SELECT NAME FROM T_0054 WHERE ID = ?");
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                result = rs.getString(1);
            }
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }

        return result;
    }

    // テーブルから値を取得するメソッド
    public static double getTableValue(int id) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        double result = 0;

        try {
            conn = DriverManager.getConnection("jdbc:default:connection:");
            pstmt = conn.prepareStatement("SELECT VALUE FROM T_0054 WHERE ID = ?");
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                result = rs.getDouble(1);
            }
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }

        return result;
    }

    // テーブルにデータを挿入するメソッド
    public static int insertData(int id, String name, double value) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        int result = 0;

        try {
            conn = DriverManager.getConnection("jdbc:default:connection:");
            pstmt = conn.prepareStatement(
                "INSERT INTO T_0054 (ID, NAME, VALUE, CREATED_DATE) VALUES (?, ?, ?, SYSDATE)");
            pstmt.setInt(1, id);
            pstmt.setString(2, name);
            pstmt.setDouble(3, value);

            result = pstmt.executeUpdate();
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }

        return result;
    }
}
/

-- 2. 修正したPL/SQLラッパー
-- 挨拶を返す関数
CREATE OR REPLACE FUNCTION SCT_0054_GET_GREETING
RETURN VARCHAR2
AS LANGUAGE JAVA
NAME 'SCT_0054_JavaProc.getGreeting() return java.lang.String';
/

-- テーブルから名前を取得する関数
CREATE OR REPLACE FUNCTION SCT_0054_GET_TABLE_NAME(
    p_id IN NUMBER
) RETURN VARCHAR2
AS LANGUAGE JAVA
NAME 'SCT_0054_JavaProc.getTableName(int) return java.lang.String';
/

-- テーブルから値を取得する関数
CREATE OR REPLACE FUNCTION SCT_0054_GET_TABLE_VALUE(
    p_id IN NUMBER
) RETURN NUMBER
AS LANGUAGE JAVA
NAME 'SCT_0054_JavaProc.getTableValue(int) return double';
/

-- テーブルからデータを取得するプロシージャ（純粋なPL/SQL）
CREATE OR REPLACE PROCEDURE SCT_0054_GET_TABLE_DATA(
    p_id IN NUMBER,
    p_name OUT VARCHAR2,
    p_value OUT VARCHAR2
)
IS
BEGIN
    p_name := SCT_0054_GET_TABLE_NAME(p_id);
    p_value := TO_CHAR(SCT_0054_GET_TABLE_VALUE(p_id));
END;
/

-- テーブルにデータを挿入する関数
CREATE OR REPLACE FUNCTION SCT_0054_INSERT_DATA(
    p_id IN NUMBER,
    p_name IN VARCHAR2,
    p_value IN NUMBER
) RETURN NUMBER
AS LANGUAGE JAVA
NAME 'SCT_0054_JavaProc.insertData(int, java.lang.String, double) return int';
/
