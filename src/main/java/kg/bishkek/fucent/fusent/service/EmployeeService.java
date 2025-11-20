package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.EmployeeDtos.*;

import java.util.List;
import java.util.UUID;

public interface EmployeeService {
    EmployeeResponse createEmployee(CreateEmployeeRequest request);
    List<EmployeeResponse> getMyEmployees();
    List<EmployeeResponse> getEmployeesByShop(UUID shopId);
    EmployeeResponse updateEmployee(UUID employeeId, UpdateEmployeeRequest request);
    EmployeeResponse updateEmployeeShop(UUID employeeId, UpdateEmployeeShopRequest request);
    void deleteEmployee(UUID employeeId);
}
