public class ContactHelper {

    /**
     * Get contacts by account
     * @param accountId The Account ID
     * @return List of Contact records
     */
    public static List<Contact> getContactsByAccount(Id accountId) {
        return [
            SELECT Id, Name, Email, Phone, Title
            FROM Contact
            WHERE AccountId = :accountId
            ORDER BY LastName, FirstName
        ];
    }

    /**
     * Send welcome email to new contacts
     * @param contactIds List of Contact IDs
     */
    public static void sendWelcomeEmail(List<Id> contactIds) {
        List<Contact> contacts = [
            SELECT Id, Email, FirstName
            FROM Contact
            WHERE Id IN :contactIds
            AND Email != null
        ];

        for (Contact c : contacts) {
            // TODO: Implement email sending logic
            System.debug('Sending welcome email to: ' + c.Email);
        }
    }

    /**
     * Update contact description
     * @param contactId The Contact ID
     */
    public static void updateContactDescription(Id contactId, String description) {
        Contact c = new Contact(Id = contactId);
        c.Description = description;
        update c;
    }
}
