@isTest
private class ContactControllerTest {
  @isTest
  static void testGetAllContacts() {
    List<Contact__c> testContacts = new List<Contact__c>();
    for (Integer i = 0; i < 5; i++) {
      testContacts.add(
        new Contact__c(
          First_Name__c = 'First' + i,
          Last_Name__c = 'Last' + i,
          Phone__c = '12345678' + i,
          Address__c = 'Address' + i,
          Mail__c = 'mail' + i + '@example.com'
        )
      );
    }
    insert testContacts;

    Test.startTest();
    List<Contact__c> result = ContactController.getAllContacts();
    Test.stopTest();
    System.assertEquals(5, result.size(),'Testing');
  }

  @isTest
  static void testViewContact() {
    Contact__c testContact = new Contact__c(
      First_Name__c = 'TestFirst',
      Last_Name__c = 'TestLast',
      Phone__c = '1234567890',
      Address__c = 'TestAddress',
      Mail__c = 'test@example.com'
    );
    insert testContact;
    Test.startTest();
    Contact__c result = ContactController.viewContact(testContact.Id);
    Test.stopTest();

    System.assertEquals(testContact.Id, result.Id,'Testing');
    System.assertEquals(testContact.First_Name__c, result.First_Name__c,'Testing');
    System.assertEquals(testContact.Last_Name__c, result.Last_Name__c,'Testing');
    System.assertEquals(testContact.Phone__c, result.Phone__c,'Testing');
    System.assertEquals(testContact.Address__c, result.Address__c,'Testing');
    System.assertEquals(testContact.Mail__c, result.Mail__c,'Testing');
  }

  @isTest
  static void testDeleteContact() {
    Contact__c testContact = new Contact__c(
      First_Name__c = 'TestFirst',
      Last_Name__c = 'TestLast',
      Phone__c = '1234567890',
      Address__c = 'TestAddress',
      Mail__c = 'test@example.com'
    );
    insert testContact;

    Test.startTest();
    ContactController.deleteContact(testContact.Id);
    Test.stopTest();

    List<SObject> deletedContact = [
      SELECT ID, First_Name__c, Last_Name__c, Phone__c, Address__c, Mail__c
      FROM Contact__c
      WHERE Phone__c = :testContact.Phone__c
    ];

    System.assertEquals(deletedContact.isEmpty(), true,'Testing');
  }

  @isTest
  static void testEditContact() {
    Contact__c testContact = new Contact__c(
      First_Name__c = 'TestFirst',
      Last_Name__c = 'TestLast',
      Phone__c = '1234567890',
      Address__c = 'TestAddress',
      Mail__c = 'test@example.com'
    );
    insert testContact;

    testContact.First_Name__c = 'UpdatedFirst';
    testContact.Last_Name__c = 'UpdatedLast';

    Test.startTest();
    ContactController.editContact(testContact);
    Test.stopTest();

    Contact__c updatedContact = [
      SELECT Id, First_Name__c, Last_Name__c
      FROM Contact__c
      WHERE Id = :testContact.Id
    ];

    System.assertEquals('UpdatedFirst', updatedContact.First_Name__c,'Testing');
    System.assertEquals('UpdatedLast', updatedContact.Last_Name__c,'Testing');
  }

  @isTest
  static void testUploadContact() {
    Contact__c testContact = new Contact__c(
      First_Name__c = 'TestFirst',
      Last_Name__c = 'TestLast',
      Phone__c = '1234567890',
      Address__c = 'TestAddress',
      Mail__c = 'test@example.com'
    );

    Test.startTest();
    ContactController.uploadContact(testContact);
    Test.stopTest();

    Contact__c uploadedContact = [
      SELECT ID, First_Name__c, Last_Name__c, Phone__c, Address__c, Mail__c
      FROM Contact__c
      WHERE Phone__c = :testContact.Phone__c
    ];
    System.assertNotEquals(null, uploadedContact,'Testing');
  }

  @isTest
  static void testSearchContact() {
    List<Contact__c> contacts = new List<Contact__c>();
    contacts.add(
      new Contact__c(
        First_Name__c = 'Test_Name',
        Last_Name__c = 'Test_Last_Name',
        Phone__c = '123-456-7890',
        Address__c = 'Baku city',
        Mail__c = 'mail@example.com'
      )
    );
    insert contacts;

    List<Contact__c> searchResults = ContactController.searchContact('Test_Name');

    System.assertEquals(
      1,
      searchResults.size(),
      'Search did not return the expected number of results.'
    );
    Contact__c foundContact = searchResults[0];
    System.assertEquals(
      'Test_Name',
      foundContact.First_Name__c,
      'First name does not match.'
    );
  }
}
