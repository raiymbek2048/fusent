package kg.bishkek.fucent.fusent.converter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import kg.bishkek.fucent.fusent.enums.Role;

@Converter(autoApply = true)
public class RoleConverter implements AttributeConverter<Role, String> {

    @Override
    public String convertToDatabaseColumn(Role role) {
        if (role == null) {
            return null;
        }
        return role.name().toLowerCase();
    }

    @Override
    public Role convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.isEmpty()) {
            return null;
        }
        return Role.valueOf(dbData.toUpperCase());
    }
}
