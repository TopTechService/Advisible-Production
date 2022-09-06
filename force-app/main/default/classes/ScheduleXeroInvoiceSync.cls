global class ScheduleXeroInvoiceSync implements schedulable{
    global void execute(SchedulableContext SC) {
        getXeroInvoices.executeCallout();
    }
}