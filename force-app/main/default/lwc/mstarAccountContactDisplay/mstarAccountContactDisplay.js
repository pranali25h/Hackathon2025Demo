/**
 * @description Lightning Web Component to display Account records with related Contacts
 * Features:
 * - Display accounts with search functionality
 * - Single account selection
 * - Display related contacts for selected account
 * - Pagination for both account and contact tables
 * - 10 records per page for both tables
 */

import { LightningElement, track } from 'lwc';
import getAccounts from '@salesforce/apex/mstar_AccountContactHelper.getAccounts';
import getContacts from '@salesforce/apex/mstar_AccountContactHelper.getContacts';
import getAccountsCount from '@salesforce/apex/mstar_AccountContactHelper.getAccountsCount';
import getContactsCount from '@salesforce/apex/mstar_AccountContactHelper.getContactsCount';

const RECORDS_PER_PAGE = 10;

export default class MstarAccountContactDisplay extends LightningElement {
  // Account related properties
  @track accountData = [];
  @track selectedAccount = null;
  @track searchKey = '';
  @track currentAccountPage = 1;
  @track totalAccountPages = 1;
  @track totalAccountRecords = 0;

  // Contact related properties
  @track contactData = [];
  @track currentContactPage = 1;
  @track totalContactPages = 1;
  @track totalContactRecords = 0;

  // UI state properties
  @track isLoading = false;
  @track errorMessage = '';

  // Account datatable columns definition
  accountColumns = [];

  // Contact datatable columns definition
  contactColumns = [
    {
      label: 'First Name',
      fieldName: 'FirstName',
      type: 'text',
      sortable: true
    },
    {
      label: 'Last Name',
      fieldName: 'LastName',
      type: 'text',
      sortable: true
    },
    {
      label: 'Email',
      fieldName: 'Email',
      type: 'email',
      sortable: true
    }
  ];

  /**
   * Lifecycle hook - Initializes component on load
   */
  connectedCallback() {
    this.loadAccounts();
  }

  /**
   * Loads accounts from the server
   * @param {number} pageNumber - Page number to load
   */
  loadAccounts(pageNumber = 1) {
    this.isLoading = true;
    this.errorMessage = '';
    console.log('Loading accounts with searchKey:', this.searchKey, 'pageNumber:', pageNumber);

    getAccounts({
      searchKey: this.searchKey,
      pageNumber: pageNumber
    })
      .then((result) => {
        console.log('Accounts loaded:', result);
        if (result) {
          this.accountData = result;
          this.currentAccountPage = pageNumber;
          
          // Get total count to calculate pagination
          return this.getAccountCount();
        }
      })
      .then((count) => {
        if (count !== undefined) {
          this.totalAccountRecords = count;
          this.totalAccountPages = Math.ceil(count / RECORDS_PER_PAGE);
          console.log('Total pages:', this.totalAccountPages);
          
          // Reset contact data when new accounts are loaded
          this.contactData = [];
          this.selectedAccount = null;
          this.selectedAccountIds = [];
        }
      })
      .catch((error) => {
        this.errorMessage =
          'Error loading accounts: ' + (error.body?.message || error.message);
        console.error('Error loading accounts:', error);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  /**
   * Gets total account count for pagination
   */
  getAccountCount() {
    return getAccountsCount({ searchKey: this.searchKey })
      .then((count) => {
        console.log('Account count:', count);
        return count;
      })
      .catch((error) => {
        console.error('Error getting account count:', error);
        return 0;
      });
  }

  /**
   * Loads contacts for the selected account
   * @param {string} accountId - The account ID
   * @param {number} pageNumber - Page number to load
   */
  loadContacts(accountId, pageNumber = 1) {
    this.isLoading = true;
    this.errorMessage = '';
    console.log('Loading contacts for account:', accountId, 'pageNumber:', pageNumber);

    getContacts({
      accountId: accountId,
      pageNumber: pageNumber
    })
      .then((result) => {
        console.log('Contacts loaded:', result);
        if (result) {
          this.contactData = result;
          this.currentContactPage = pageNumber;
          
          // Get total count to calculate pagination
          return this.getContactCount(accountId);
        }
      })
      .then((count) => {
        if (count !== undefined) {
          this.totalContactRecords = count;
          this.totalContactPages = Math.ceil(count / RECORDS_PER_PAGE);
          console.log('Total contact pages:', this.totalContactPages);
        }
      })
      .catch((error) => {
        this.errorMessage =
          'Error loading contacts: ' + (error.body?.message || error.message);
        console.error('Error loading contacts:', error);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  /**
   * Gets total contact count for pagination
   */
  getContactCount(accountId) {
    return getContactsCount({ accountId: accountId })
      .then((count) => {
        console.log('Contact count:', count);
        return count;
      })
      .catch((error) => {
        console.error('Error getting contact count:', error);
        return 0;
      });
  }

  /**
   * Getter to check if on first account page
   */
  get isAccountFirstPage() {
    return this.currentAccountPage === 1;
  }

  /**
   * Getter to check if on last account page
   */
  get isAccountLastPage() {
    return this.currentAccountPage >= this.totalAccountPages;
  }

  /**
   * Getter to check if on first contact page
   */
  get isContactFirstPage() {
    return this.currentContactPage === 1;
  }

  /**
   * Getter to check if on last contact page
   */
  get isContactLastPage() {
    return this.currentContactPage >= this.totalContactPages;
  }

  /**
   * Getter to return account data with selection status
   */
  get accountDataWithSelection() {
    return this.accountData.map((account) => ({
      ...account,
      isSelected: this.selectedAccount && this.selectedAccount.Id === account.Id
    }));
  }

  /**
   * Handles search input change
   * @param {Event} event - The change event
   */
  handleSearchChange(event) {
    this.searchKey = event.target.value;
    this.currentAccountPage = 1;
    this.selectedAccount = null;
    this.contactData = [];
    this.loadAccounts(1);
  }

  /**
   * Handles account row action (Select button click)
   * @param {Event} event - The row action event
   */
  handleAccountRowAction(event) {
    const action = event.detail.action;
    const row = event.detail.row;

    console.log('Row action triggered:', action, 'Row:', row);

    if (action.name === 'select_action') {
      this.selectedAccount = row;
      console.log('Account selected:', this.selectedAccount);
      this.currentContactPage = 1;
      this.loadContacts(this.selectedAccount.Id, 1);
    }
  }

  /**
   * Handles radio button change for account selection
   * @param {Event} event - The change event
   */
  handleRadioChange(event) {
    const selectedAccountId = event.target.value;
    console.log('Radio button selected, Account ID:', selectedAccountId);

    // Find the selected account from the current page data
    const selectedAcc = this.accountData.find(
      (acc) => acc.Id === selectedAccountId
    );

    if (selectedAcc) {
      this.selectedAccount = selectedAcc;
      console.log('Account selected:', this.selectedAccount);
      this.currentContactPage = 1;
      this.loadContacts(this.selectedAccount.Id, 1);
    }
  }

  /**
   * Handles previous button click for accounts
   */
  handlePreviousAccounts() {
    if (this.currentAccountPage > 1) {
      this.currentAccountPage--;
      this.loadAccounts(this.currentAccountPage);
    }
  }

  /**
   * Handles next button click for accounts
   */
  handleNextAccounts() {
    if (this.currentAccountPage < this.totalAccountPages) {
      this.currentAccountPage++;
      this.loadAccounts(this.currentAccountPage);
    }
  }

  /**
   * Handles previous button click for contacts
   */
  handlePreviousContacts() {
    if (this.currentContactPage > 1) {
      this.currentContactPage--;
      this.loadContacts(this.selectedAccount.Id, this.currentContactPage);
    }
  }

  /**
   * Handles next button click for contacts
   */
  handleNextContacts() {
    if (this.currentContactPage < this.totalContactPages) {
      this.currentContactPage++;
      this.loadContacts(this.selectedAccount.Id, this.currentContactPage);
    }
  }

  /**
   * Handles error alert close
   */
  handleCloseError() {
    this.errorMessage = '';
  }
}
