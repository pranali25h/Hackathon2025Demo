/**
 * @description Apex helper class for Account and Contact data retrieval
 * This class provides methods to fetch accounts with search and pagination support,
 * and to fetch related contacts for a selected account with pagination support.
 */
public with sharing class mstar_AccountContactHelper {
  /**
   * Private constant for records per page
   */
  private static final Integer RECORDS_PER_PAGE = 10;

  /**
   * Fetches accounts based on search criteria with pagination support
   * @param searchKey Search term to filter accounts by name
   * @param pageNumber Page number for pagination (1-based)
   * @return List of Account records for the specified page
   * @throws AuraHandledException If there's an error retrieving accounts
   */
  @AuraEnabled
  public static List<Account> getAccounts(String searchKey, Integer pageNumber) {
    try {
      // Validate input parameters
      if (pageNumber == null || pageNumber < 1) {
        pageNumber = 1;
      }
      if (searchKey == null) {
        searchKey = '';
      }

      // Build search string for SOQL LIKE operator
      String searchTerm = '%' + String.escapeSingleQuotes(searchKey) + '%';

      // Calculate offset for pagination
      Integer offset = (pageNumber - 1) * RECORDS_PER_PAGE;

      // Query accounts with search filter and pagination
      List<Account> accounts = [
        SELECT
          Id,
          Name,
          Account_ID__c,
          Account_Type__c,
          CreatedDate
        FROM Account
        WHERE Name LIKE :searchTerm
        ORDER BY CreatedDate DESC
        LIMIT :RECORDS_PER_PAGE
        OFFSET :offset
      ];

      return accounts;
    } catch (Exception ex) {
      throw new AuraHandledException(
        'Error retrieving accounts: ' + ex.getMessage()
      );
    }
  }

  /**
   * Fetches related contacts for a specified account with pagination support
   * @param accountId The Account ID to fetch contacts for
   * @param pageNumber Page number for pagination (1-based)
   * @return List of Contact records for the specified account and page
   * @throws AuraHandledException If there's an error retrieving contacts
   */
  @AuraEnabled
  public static List<Contact> getContacts(String accountId, Integer pageNumber) {
    try {
      // Validate input parameters
      if (String.isBlank(accountId)) {
        throw new AuraHandledException('Account ID is required');
      }
      if (pageNumber == null || pageNumber < 1) {
        pageNumber = 1;
      }

      // Calculate offset for pagination
      Integer offset = (pageNumber - 1) * RECORDS_PER_PAGE;

      // Query contacts for the specified account with pagination
      List<Contact> contacts = [
        SELECT Id, FirstName, LastName, Email
        FROM Contact
        WHERE AccountId = :accountId
        ORDER BY CreatedDate DESC
        LIMIT :RECORDS_PER_PAGE
        OFFSET :offset
      ];

      return contacts;
    } catch (Exception ex) {
      throw new AuraHandledException(
        'Error retrieving contacts: ' + ex.getMessage()
      );
    }
  }

  /**
   * Gets total count of accounts based on search criteria
   * @param searchKey Search term to filter accounts by name
   * @return Total count of accounts matching the search criteria
   */
  @AuraEnabled
  public static Integer getAccountsCount(String searchKey) {
    try {
      if (searchKey == null) {
        searchKey = '';
      }

      String searchTerm = '%' + String.escapeSingleQuotes(searchKey) + '%';

      Integer accountCount = [
        SELECT COUNT()
        FROM Account
        WHERE Name LIKE :searchTerm
      ];

      return accountCount;
    } catch (Exception ex) {
      throw new AuraHandledException(
        'Error retrieving account count: ' + ex.getMessage()
      );
    }
  }

  /**
   * Gets total count of contacts for a specified account
   * @param accountId The Account ID to count contacts for
   * @return Total count of contacts for the account
   */
  @AuraEnabled
  public static Integer getContactsCount(String accountId) {
    try {
      if (String.isBlank(accountId)) {
        throw new AuraHandledException('Account ID is required');
      }

      Integer contactCount = [
        SELECT COUNT()
        FROM Contact
        WHERE AccountId = :accountId
      ];

      return contactCount;
    } catch (Exception ex) {
      throw new AuraHandledException(
        'Error retrieving contact count: ' + ex.getMessage()
      );
    }
  }
}
