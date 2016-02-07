//
//  ProductsTableViewController.m
//  CoreDataSample
//
//  Created by Sergey Zalozniy on 01/02/16.
//  Copyright © 2016 GeekHub. All rights reserved.
//

#import "CoreDataManager.h"

#import "CDBasket.h"
#import "CDProduct.h"

#import "ProductsTableViewController.h"

@interface ProductsTableViewController () <UITableViewDelegate>

@property (strong, nonatomic) NSArray *items;
@property (nonatomic, strong) CDBasket *basket;

@end

@implementation ProductsTableViewController

#pragma mark - Instance initialization

+(instancetype) instanceControllerWithBasket:(CDBasket *)basket {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProductsTableViewController *controller = [sb instantiateViewControllerWithIdentifier:@"ProductsTableViewControllerIdentifier"];
    controller.basket = basket;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchProducts];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewProduct:)];
    [self refreshData];
}

#pragma mark - Action methods

-(void) addNewProduct:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"New Product" message:@"Enter name, price and number" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [controller addAction:action];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypeDefault];
        textField.placeholder = @"Product name";
    }];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypeDecimalPad];
        textField.placeholder = @"Price";
    }];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        textField.placeholder = @"Number";
    }];
    action = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textFieldName = controller.textFields[0];
        NSDecimalNumber * price = [[NSDecimalNumber alloc]initWithString:controller.textFields[1].text];
        NSInteger number = [controller.textFields[2].text intValue];
        [self createProductWithName:textFieldName.text andPrice:price andNumber:number];
    }];
    
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void) addActualPriceForProduct:(CDProduct *)product atIndexPath:(NSIndexPath*)indexPath {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Actual Price" message:@"Enter actual price of product" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [controller addAction:action];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypeDecimalPad];
        textField.placeholder = @"Actual price";
    }];
    action = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDecimalNumber * actualPrice = [[NSDecimalNumber alloc]initWithString:controller.textFields[0].text];
        product.actualPrice = actualPrice;
        [[CoreDataManager sharedInstance] saveContext];
        [self refreshData];
    }];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void) editNameNumberAndPriceForProduct:(CDProduct*)product atIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Edit mode" message:@"Edit what you want" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [controller addAction:action];
    
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypeDefault];
        textField.placeholder = [NSString stringWithFormat:@"Current product name: %@", product.name];
    }];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypeDecimalPad];
        textField.placeholder = [NSString stringWithFormat:@"Current price: %@", product.price];
    }];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        textField.placeholder = [NSString stringWithFormat:@"Current numbers of product: %ld", (long)product.number];
    }];
    action = [UIAlertAction actionWithTitle:@"Change" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //Checked for changes
        if (controller.textFields[0].text.length >= 2) {
            product.name = controller.textFields[0].text;
        } else {
            NSLog(@"Name not changed. Length of name is less than 2 symbols");
        }
        
        if (controller.textFields[1].text.length >= 1) {
            NSDecimalNumber * price = [[NSDecimalNumber alloc]initWithString:controller.textFields[1].text];
            product.price = price;
        } else {
            NSLog(@"Price not changed. Length of price is less than 1 number");
        }
        if (controller.textFields[2].text.length >=1 ) {
            NSInteger number = [controller.textFields[2].text intValue];
            product.number = number;
        } else {
            NSLog(@"Number not changed. Length of number is less than 1 number");
        }
        [[CoreDataManager sharedInstance] saveContext];
        [self refreshData];
    }];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - Private methods

-(void) refreshData {
    self.items = [self fetchProducts];
    [self.tableView reloadData];
}

-(void) createProductWithName:(NSString *)name andPrice:(NSDecimalNumber *)price andNumber:(NSInteger)number{

    NSManagedObjectContext *context = [CoreDataManager sharedInstance].managedObjectContext;
    CDProduct *product = [NSEntityDescription insertNewObjectForEntityForName:[[CDProduct class] description]
                                                       inManagedObjectContext:context];
    product.name = name;
    product.price = price;
    product.number = number;
    [self.basket addProductsObject:product];
    [[CoreDataManager sharedInstance] saveContext];
    [self refreshData];
}

-(NSArray *) fetchProducts {
    NSManagedObjectContext *context = [CoreDataManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[[CDProduct class] description]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"basket = %@", self.basket.objectID];
    request.predicate = predicate;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    return [context executeFetchRequest:request error:nil];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CDProduct *product = self.items[indexPath.row];
    UIAlertController * alertController = [self createAlertForProduct:product atIndexPath:indexPath];
    [self presentViewController:alertController animated:YES completion:nil];
    
 }

- (UIAlertController *) createAlertForProduct:(CDProduct *)product atIndexPath: (NSIndexPath *) indexPath {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Edit mode"
                                          message:@"What to do?"
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *editAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Edit", @"Edit action")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action)
                                 {
                                     NSLog(@"Edit action");
                                     [self editNameNumberAndPriceForProduct:product atIndexPath:indexPath];
                                     [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                                 }];
    
    UIAlertAction *buyAction = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"Mark as Bought", @"Mark as Bought action")
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action)
                                {
                                    NSLog(@"Buyed action");
                                    product.complete = @YES;
                                    [self addActualPriceForProduct:product atIndexPath:indexPath];
                                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                }];
    
    UIAlertAction *unBuyAction = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"Mark as Unbought", @"Mark as Unbought action")
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action)
                                {
                                    NSLog(@"Unbuyed action");
                                    product.complete = @NO;
                                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                }];
    
    UIAlertAction *deleteAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Delete", @"Delete action")
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Delete action");
                                       [self deleteProduct:product inTableView:self.tableView forRowAtIndexPath:indexPath];
                                       [[CoreDataManager sharedInstance] saveContext];
                                       [self refreshData];
                                   }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                       [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                                   }];
    
    [alertController addAction:deleteAction];
    [alertController addAction:editAction];
    if ([product.complete boolValue]) {
        [alertController addAction:unBuyAction];
    } else {
        [alertController addAction:buyAction];
    }
    [alertController addAction:cancelAction];
    return alertController;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    CDProduct *product = self.items[indexPath.row];
    cell.textLabel.text = product.name;
    if ([product.complete boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (void) deleteProduct: (CDProduct *)product inTableView: (UITableView *)tableView forRowAtIndexPath: (NSIndexPath *)indexPath {
    //CDProduct *product = self.items[indexPath.row];
    [[CoreDataManager sharedInstance].managedObjectContext deleteObject:product];
    NSMutableArray *items = [self.items mutableCopy];
    [items removeObject:product];
    self.items = [items copy];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 2;
//}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
