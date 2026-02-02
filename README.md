# Mamori DAM Demo Guide

This guide describes how to set up and demonstrate **Mamori Database Activity Monitoring (DAM)** using a SQL Server lab environment.

---

## Prerequisites

Before starting, ensure the following components are already running:

- SQL Server (Docker-based)
- Mamori platform (Docker or VM)
- Network connectivity between Mamori and SQL Server
- A SQL Server account available for Mamori to use

---

## 1. Add the SQL Server Datasource

1. After setting up SQL Server, note the **host** and **port** it is listening on.
2. Log in to the Mamori UI.
3. Navigate to:

   **Datasources → Add Datasource**

4. Enter the SQL Server connection details (host, port, credentials).
5. Save the datasource.
6. Click **Verify Connection** to confirm Mamori can successfully connect.

---

## 2. Create a Mamori User and Grant Datasource Access

1. In the Mamori UI, navigate to:

   **Users → Add New User**

2. In the **General** tab:
   - Assign appropriate roles, for example:
     - `default_database_credentials`
     - `default_database_access_ro`

3. Navigate to the **Database & Access** tab:
   - Under **Credentials**, add database credentials for the SQL Server datasource.
   - Select an existing database account.
     - By default, only `SA` may exist.
     - **Recommendation:** create a dedicated, non-SA account in SQL Server for demo purposes.

4. Save the user.

This user will be used to demonstrate monitored database access.

---

## 3. Log In as the New User and Verify Activity Logging

1. Log out of the admin account.
2. Log in using the newly created Mamori user.
3. Navigate to:

   **Web SQL**

4. Run one or more test queries, for example:

   ```sql
   SELECT FullName, PhoneNumber, EmailAddress
   FROM Application.People;
   ```
or
   ```sql
   SELECT TOP 10 *
   FROM Sales.Orders
   ORDER BY OrderDate DESC;
   ```

5. After activity is generated, navigate to:

   **Logs → Query Session Log**

6. Verify that:
   - User activity is recorded
   - The correct user identity is shown
   - Database objects and timestamps are visible

This confirms Mamori is successfully monitoring database activity.

---

## 4. Create and Test a Policy

1. Navigate to:

   **Policies → Statement Policies → Add New Policy**

2. Configure a policy, for example:
   - Restrict access to a sensitive table or schema
   - Block specific statement types
   - Trigger alerts on sensitive data access

3. Save and activate the policy.

4. Return to **Web SQL** and generate activity that matches the policy conditions.

5. Observe the result:
   - Query is blocked, or
   - Alert is generated and logged (depending on policy mode)

6. Review the event in the logs to confirm enforcement or alerting.
