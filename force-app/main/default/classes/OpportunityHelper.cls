public class OpportunityHelper {

    /**
     * Get open opportunities
     * @return List of open Opportunity records
     */
    public static List<Opportunity> getOpenOpportunities() {
        return [
            SELECT Id, Name, Amount, StageName, CloseDate, AccountId
            FROM Opportunity
            WHERE IsClosed = false
            ORDER BY CloseDate ASC
            LIMIT 100
        ];
    }

    /**
     * Calculate total pipeline value
     * @return Total amount of open opportunities
     */
    public static Decimal calculatePipelineValue() {
        AggregateResult[] results = [
            SELECT SUM(Amount) totalAmount
            FROM Opportunity
            WHERE IsClosed = false
        ];

        if (results.size() > 0 && results[0].get('totalAmount') != null) {
            return (Decimal) results[0].get('totalAmount');
        }

        return 0;
    }

    /**
     * Update opportunity stage
     * @param opportunityId The Opportunity ID
     * @param newStage The new stage name
     */
    public static void updateStage(Id opportunityId, String newStage) {
        Opportunity opp = new Opportunity(Id = opportunityId);
        opp.StageName = newStage;
        update opp;
    }

    /**
     * Get opportunities closing this month
     * @return List of Opportunity records
     */
    public static List<Opportunity> getOpportunitiesClosingThisMonth() {
        Date firstDay = Date.today().toStartOfMonth();
        Date lastDay = firstDay.addMonths(1).addDays(-1);

        return [
            SELECT Id, Name, Amount, StageName, CloseDate
            FROM Opportunity
            WHERE CloseDate >= :firstDay
            AND CloseDate <= :lastDay
            ORDER BY CloseDate ASC
        ];
    }
}
