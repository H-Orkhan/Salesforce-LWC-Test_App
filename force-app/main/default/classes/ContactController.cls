public with sharing class ContactController {
  @AuraEnabled(cacheable=true)
  public static List<Contact__c> getAllContacts() {
    
    return [
      SELECT ID, First_Name__c, Last_Name__c, Phone__c, Address__c, Mail__c
      FROM Contact__c WITH SECURITY_ENFORCED
    ];
  }

  @AuraEnabled(cacheable=true)
  public static Contact__c viewContact(String contactId) {
    return [
      SELECT ID, First_Name__c, Last_Name__c, Phone__c, Address__c, Mail__c
      FROM Contact__c
      WHERE ID = :contactId WITH SECURITY_ENFORCED
    ];
  }

  @AuraEnabled
  public static void deleteContact(String contactId) {
    delete [
      SELECT ID, First_Name__c, Last_Name__c, Phone__c, Address__c, Mail__c
      FROM Contact__c
      WHERE ID = :contactId WITH SECURITY_ENFORCED
    ];
  }

  @AuraEnabled
  public static List<Contact__c> searchContact(String searchValue) {
    
    if(String.isBlank(searchValue) || String.isEmpty(searchValue)) {
      return getAllContacts();
    }

    searchValue = '%' + searchValue + '%';
    return [
      SELECT ID, First_Name__c, Last_Name__c, Phone__c, Address__c, Mail__c
      FROM Contact__c
      WHERE First_Name__c LIKE :searchValue OR 
      Last_Name__c LIKE :searchValue OR 
      Phone__c LIKE :searchValue OR
      Mail__c LIKE :searchValue OR
      Address__c LIKE :searchValue OR
      Full_Name__c LIKE :searchValue OR
      Full_Name_Reversed__c LIKE :searchValue 
      WITH SECURITY_ENFORCED
      ];
  }


  @AuraEnabled
  public static void editContact(Contact__c contact) {
    update getUpdatedContact(contact);
  }

  @AuraEnabled
  public static void uploadContact(Contact__c contact) {
    insert getNewContact(contact);
  }

  private static Contact__c getNewContact(Contact__c contact) {
    Contact__c newContact = new Contact__c();
    newContact.Last_Name__c = contact.Last_Name__c;
    newContact.First_Name__c = contact.First_Name__c;
    newContact.Mail__c = contact.Mail__c;
    newContact.Phone__c = contact.Phone__c;
    newContact.Address__c = contact.Address__c;
    return newContact;
  }

  private static Contact__c getUpdatedContact(Contact__c contact) {
    Contact__c updatedContact = new Contact__c(Id = contact.Id);
    if (checkIsNotBlank(contact.Last_Name__c)) {
      updatedContact.Last_Name__c = contact.Last_Name__c;
    }
    if (checkIsNotBlank(contact.First_Name__c)) {
      updatedContact.First_Name__c = contact.First_Name__c;
    }
    if (checkIsNotBlank(contact.Mail__c)) {
      updatedContact.Mail__c = contact.Mail__c;
    }
    if (checkIsNotBlank(contact.Phone__c)) {
      updatedContact.Phone__c = contact.Phone__c;
    }
    if (checkIsNotBlank(contact.Address__c)) {
      updatedContact.Address__c = contact.Address__c;
    }
    return updatedContact;
  }

  private static boolean checkIsNotBlank(String str) {
    return String.isNotBlank(str);
  }
}
