/* eslint-disable no-restricted-globals */
/* eslint-disable no-alert */
import { LightningElement, wire, track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getAllContacts from '@salesforce/apex/ContactController.getAllContacts';
import viewContact from '@salesforce/apex/ContactController.viewContact';
import deleteContact from '@salesforce/apex/ContactController.deleteContact';
import editContact from '@salesforce/apex/ContactController.editContact';
import uploadContact from '@salesforce/apex/ContactController.uploadContact';
import searchContact from '@salesforce/apex/ContactController.searchContact';


export default class ContactManager extends LightningElement {
    @api searchContactComponent;
    @track contacts = [];
    selectedContact;
    isModalOpen = false;
    isFormVisible = false;
    @track isEditModalOpen = false;
    @track searchValue = '';


    editedContact = {}; 

    @track newContact = {
        First_Name__c: '',
        Last_Name__c: '',
        Mail__c: '',
        Phone__c: '',
        Address__c: '',
    };

    @wire(getAllContacts)
    wiredContacts({ error, data }) {
        if (data) {
            this.contacts = data;
        } else if (error) {
            console.error('Error fetching contacts', error);
        }
    }

    handleViewClick(event) {
        const contactId = event.target.value;
        viewContact({ contactId })
            .then(result => {
                this.selectedContact = result;
                this.isModalOpen = true;
            })
            .catch(error => {
                console.error('Error fetching contact details', error);
            });
    }

    handleDeleteClick(event) {
        const contactId = event.target.value;
        const isConfirmed = confirm('Are you sure you want to delete this contact?');
        if (isConfirmed) {
            deleteContact({ contactId })
                .then(() => {
                    this.contacts = this.contacts.filter(contact => contact.Id !== contactId);
                    return this.showSuccessfulToastEvent('deleted');
                })
                .catch(error => {
                    console.error('Error deleting contact', error);
                    return this.showFailedToastEvent();

                });
        }
    }

    handleSearchEvent(event) {
        this.searchValue = event.target.value;
        this.searchContacts();
    }

    searchContacts() {
            searchContact({ searchValue: this.searchValue })
                .then(result => {
                    this.contacts = result;
                })
                .catch(error => {
                    console.error('Error searching contacts', error);
                });
        }

    handleInputChange(event) {
        const parts = event.target.id.split('-');
        const field = parts[0];
        console.log(field);
        const value = event.target.value;
        console.log(value);
        this.newContact[field] = value;
    }

    showForm() {
        this.isFormVisible = true;
    }

    hideForm() {
        this.isFormVisible = false;
    }

    handleUploadContact() {
        uploadContact({ contact: this.newContact })
            .then(() => {
                this.newContact = {
                    First_Name__c: '',
                    Last_Name__c: '',
                    Mail__c: '',
                    Phone__c: '',
                    Address__c: '',
                };
               this.showSuccessfulToastEvent('uploaded');
               location.reload();
            })
            .catch(error => {
                console.error('Error uploading contact', error);
                this.showFailedToastEvent();
            });
    }

    handleEditClick(event) {
        const contactId = event.target.value;
        viewContact({ contactId })
            .then(result => {
                this.editedContact = { ...result };
                this.isEditModalOpen = true;
            })
            .catch(error => {
                console.error('Error fetching contact details for editing', error);
            });
    }

    handleEditInputChange(event) {
        const parts = event.target.id.replace('edit_','').split('-');
        const field = parts[0];
        const value = event.target.value;
        this.editedContact[field] = value;
    }

    handleSaveContact() {
        editContact({ contact: this.editedContact })
            .then(() => {
                this.isEditing = false; 
               this.showSuccessfulToastEvent('edited');
               location.reload();
            })
            .catch(error => {
                console.error('Error updating contact', error);
                this.showFailedToastEvent();
            });
    }

    closeEditModal() {
        this.isEditModalOpen = false; 
        this.editedContact = { ...this.selectedContact };
    }

    closeModal() {
        this.isModalOpen = false;
    }

    showSuccessfulToastEvent (action) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'You '+action+' Contact',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        return refreshApex(this.wiredContacts);
    }

    showFailedToastEvent() {
        const event = new ShowToastEvent({
            title: 'Fail',
            message: 'Some problem was happened',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        return refreshApex(this.wiredContacts);
    }
}
