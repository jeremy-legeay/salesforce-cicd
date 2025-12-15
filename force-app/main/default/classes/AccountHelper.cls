public class AccountHelper {

    /**
     * Get active accounts
     * @return List of active Account records
     */
    public static List<Account> getActiveAccounts() {
        return [
            SELECT Id, Name, Industry, AnnualRevenue
            FROM Account
            ORDER BY Name
            LIMIT 100
        ];
    }

    /**
     * Update account rating based on revenue
     * @param accountId The Account ID to update
     * @param revenue The annual revenue
     */
    public static void updateAccountRating(Id accountId, Decimal revenue) {
        Account acc = new Account(Id = accountId);

        if (revenue >= 1000000) {
            acc.Rating = 'Hot';
        } else if (revenue >= 100000) {
            acc.Rating = 'Warm';
        } else {
            acc.Rating = 'Cold';
        }

        update acc;
    }
}
