/**
 * @description Test class for mstar_AccountContactHelper
 * Provides comprehensive unit test coverage for account and contact retrieval methods
 * Test coverage includes: getAccounts, getContacts, getAccountsCount, and getContactsCount
 */
@isTest
private class mstar_AccountContactHelperTest {
  @TestSetup
  static void setupTestData() {
    // Create test accounts
    List<Account> testAccounts = new List<Account>();
    for (Integer i = 1; i <= 25; i++) {
      testAccounts.add(
        new Account(
          Name = 'Test Account ' + i,
          AccountNumber = 'ACC-' + i,
          Type = 'Customer'
        )
      );
    }
    insert testAccounts;

    // Create test contacts for first 3 accounts
    List<Contact> testContacts = new List<Contact>();
    List<Account> accounts = [SELECT Id FROM Account LIMIT 3];

    for (Account acc : accounts) {
      for (Integer i = 1; i <= 15; i++) {
        testContacts.add(
          new Contact(
            FirstName = 'First' + i,
            LastName = 'Last' + i,
            Email = 'test' + i + '@example.com',
            AccountId = acc.Id
          )
        );
      }
    }
    insert testContacts;
  }

  @isTest
  static void testGetAccountsFirstPage() {
    Test.startTest();
    List<Account> accounts = mstar_AccountContactHelper.getAccounts('', 1);
    Test.stopTest();

    System.assertNotEquals(null, accounts, 'Accounts list should not be null');
    System.assertEquals(10, accounts.size(), 'Should return 10 accounts');
  }

  @isTest
  static void testGetAccountsSecondPage() {
    Test.startTest();
    List<Account> accounts = mstar_AccountContactHelper.getAccounts('', 2);
    Test.stopTest();

    System.assertNotEquals(null, accounts, 'Accounts list should not be null');
    System.assertEquals(10, accounts.size(), 'Should return 10 accounts');
  }

  @isTest
  static void testGetAccountsWithSearch() {
    Test.startTest();
    List<Account> accounts = mstar_AccountContactHelper.getAccounts(
      'Test Account 1',
      1
    );
    Test.stopTest();

    System.assertNotEquals(null, accounts, 'Accounts list should not be null');
    System.assert(
      accounts.size() > 0,
      'Should return at least one matching account'
    );
    for (Account acc : accounts) {
      System.assert(
        acc.Name.contains('Test Account 1'),
        'Account name should contain search term'
      );
    }
  }

  @isTest
  static void testGetAccountsWithNullSearchKey() {
    Test.startTest();
    List<Account> accounts = mstar_AccountContactHelper.getAccounts(null, 1);
    Test.stopTest();

    System.assertNotEquals(null, accounts, 'Accounts list should not be null');
    System.assert(accounts.size() > 0, 'Should return accounts');
  }

  @isTest
  static void testGetAccountsWithNullPageNumber() {
    Test.startTest();
    List<Account> accounts = mstar_AccountContactHelper.getAccounts('', null);
    Test.stopTest();

    System.assertNotEquals(null, accounts, 'Accounts list should not be null');
    System.assertEquals(10, accounts.size(), 'Should return 10 accounts');
  }

  @isTest
  static void testGetAccountsWithInvalidPageNumber() {
    Test.startTest();
    List<Account> accounts = mstar_AccountContactHelper.getAccounts('', 0);
    Test.stopTest();

    System.assertNotEquals(null, accounts, 'Accounts list should not be null');
    System.assertEquals(10, accounts.size(), 'Should return 10 accounts');
  }

  @isTest
  static void testGetAccountsNoMatch() {
    Test.startTest();
    List<Account> accounts = mstar_AccountContactHelper.getAccounts(
      'NonExistent',
      1
    );
    Test.stopTest();

    System.assertNotEquals(null, accounts, 'Accounts list should not be null');
    System.assertEquals(0, accounts.size(), 'Should return no accounts');
  }

  @isTest
  static void testGetAccountsWithSpecialCharacters() {
    Test.startTest();
    List<Account> accounts = mstar_AccountContactHelper.getAccounts(
      'Test',
      1
    );
    Test.stopTest();

    System.assertNotEquals(null, accounts, 'Accounts list should not be null');
  }

  @isTest
  static void testGetContactsFirstPage() {
    Account testAccount = [SELECT Id FROM Account LIMIT 1];

    Test.startTest();
    List<Contact> contacts = mstar_AccountContactHelper.getContacts(
      testAccount.Id,
      1
    );
    Test.stopTest();

    System.assertNotEquals(null, contacts, 'Contacts list should not be null');
    System.assertEquals(10, contacts.size(), 'Should return 10 contacts');
  }

  @isTest
  static void testGetContactsSecondPage() {
    Account testAccount = [SELECT Id FROM Account LIMIT 1];

    Test.startTest();
    List<Contact> contacts = mstar_AccountContactHelper.getContacts(
      testAccount.Id,
      2
    );
    Test.stopTest();

    System.assertNotEquals(null, contacts, 'Contacts list should not be null');
    System.assert(
      contacts.size() > 0,
      'Should return contacts on second page'
    );
  }

  @isTest
  static void testGetContactsWithNullAccountId() {
    Test.startTest();
    try {
      mstar_AccountContactHelper.getContacts(null, 1);
      System.assert(false, 'Should throw exception for null account ID');
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage().contains('Account ID is required'),
        'Should return appropriate error message'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testGetContactsWithBlankAccountId() {
    Test.startTest();
    try {
      mstar_AccountContactHelper.getContacts('', 1);
      System.assert(false, 'Should throw exception for blank account ID');
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage().contains('Account ID is required'),
        'Should return appropriate error message'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testGetContactsWithNullPageNumber() {
    Account testAccount = [SELECT Id FROM Account LIMIT 1];

    Test.startTest();
    List<Contact> contacts = mstar_AccountContactHelper.getContacts(
      testAccount.Id,
      null
    );
    Test.stopTest();

    System.assertNotEquals(null, contacts, 'Contacts list should not be null');
    System.assertEquals(10, contacts.size(), 'Should return 10 contacts');
  }

  @isTest
  static void testGetContactsEmptyResult() {
    Account emptyAccount = new Account(Name = 'Empty Account');
    insert emptyAccount;

    Test.startTest();
    List<Contact> contacts = mstar_AccountContactHelper.getContacts(
      emptyAccount.Id,
      1
    );
    Test.stopTest();

    System.assertNotEquals(null, contacts, 'Contacts list should not be null');
    System.assertEquals(0, contacts.size(), 'Should return no contacts');
  }

  @isTest
  static void testGetAccountsCount() {
    Test.startTest();
    Integer count = mstar_AccountContactHelper.getAccountsCount('');
    Test.stopTest();

    System.assertEquals(25, count, 'Should return total account count');
  }

  @isTest
  static void testGetAccountsCountWithSearch() {
    Test.startTest();
    Integer count = mstar_AccountContactHelper.getAccountsCount(
      'Test Account 1'
    );
    Test.stopTest();

    System.assert(count > 0, 'Should return count of matching accounts');
  }

  @isTest
  static void testGetAccountsCountWithNullSearch() {
    Test.startTest();
    Integer count = mstar_AccountContactHelper.getAccountsCount(null);
    Test.stopTest();

    System.assertEquals(25, count, 'Should return total account count');
  }

  @isTest
  static void testGetContactsCount() {
    Account testAccount = [SELECT Id FROM Account LIMIT 1];

    Test.startTest();
    Integer count = mstar_AccountContactHelper.getContactsCount(
      testAccount.Id
    );
    Test.stopTest();

    System.assertEquals(15, count, 'Should return correct contact count');
  }

  @isTest
  static void testGetContactsCountWithNullAccountId() {
    Test.startTest();
    try {
      mstar_AccountContactHelper.getContactsCount(null);
      System.assert(false, 'Should throw exception for null account ID');
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage().contains('Account ID is required'),
        'Should return appropriate error message'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testGetContactsCountEmptyResult() {
    Account emptyAccount = new Account(Name = 'Empty Account');
    insert emptyAccount;

    Test.startTest();
    Integer count = mstar_AccountContactHelper.getContactsCount(
      emptyAccount.Id
    );
    Test.stopTest();

    System.assertEquals(0, count, 'Should return 0 for account with no contacts');
  }

  @isTest
  static void testGetAccountsFieldValues() {
    Test.startTest();
    List<Account> accounts = mstar_AccountContactHelper.getAccounts('', 1);
    Test.stopTest();

    System.assertNotEquals(null, accounts, 'Accounts list should not be null');
    System.assert(accounts.size() > 0, 'Should return at least one account');

    Account acc = accounts[0];
    System.assertNotEquals(null, acc.Id, 'Account ID should not be null');
    System.assertNotEquals(null, acc.Name, 'Account Name should not be null');
    System.assertNotEquals(
      null,
      acc.AccountNumber,
      'Account Number should not be null'
    );
  }

  @isTest
  static void testGetContactsFieldValues() {
    Account testAccount = [SELECT Id FROM Account LIMIT 1];

    Test.startTest();
    List<Contact> contacts = mstar_AccountContactHelper.getContacts(
      testAccount.Id,
      1
    );
    Test.stopTest();

    System.assertNotEquals(null, contacts, 'Contacts list should not be null');
    System.assert(contacts.size() > 0, 'Should return at least one contact');

    Contact con = contacts[0];
    System.assertNotEquals(null, con.Id, 'Contact ID should not be null');
    System.assertNotEquals(
      null,
      con.FirstName,
      'Contact FirstName should not be null'
    );
    System.assertNotEquals(
      null,
      con.LastName,
      'Contact LastName should not be null'
    );
  }

  @isTest
  static void testPaginationOffsetCalculation() {
    Test.startTest();
    List<Account> page1 = mstar_AccountContactHelper.getAccounts('', 1);
    List<Account> page2 = mstar_AccountContactHelper.getAccounts('', 2);
    Test.stopTest();

    System.assertNotEquals(
      page1[0].Id,
      page2[0].Id,
      'Different pages should return different records'
    );
  }
}
