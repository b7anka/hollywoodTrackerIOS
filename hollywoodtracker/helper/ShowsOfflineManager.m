//
//  ShowsOfflineManager.m
//  hollywoodtracker
//
//  Created by Tiago Moreira on 05/02/19.
//  Copyright © 2019 Tiago Moreira. All rights reserved.
//

#import "ShowsOfflineManager.h"
#import "Constants.h"
#import "AppDelegate.h"

@implementation ShowsOfflineManager

const int MAX_RANDOM_NUMER = 100;

#pragma mark - Class Methods


/**
 This method sums 1 to the user's profile movies, recent or tvshows properties based on the type that it receives as parameter and then calls the method to update the user profile

 @param type The type to be updated
 */
+(void)addShowToUser:(NSString *)type
{
    User *user = [ShowsOfflineManager allUsers].firstObject;
    
    if([type isEqualToString:MOVIES])
    {
        user.movies = [NSNumber numberWithInteger:user.movies.integerValue+1];
    }
    else if([type isEqualToString:TV_SHOWS])
    {
        user.tvShows = [NSNumber numberWithInteger:user.tvShows.integerValue+1];
    }
    else
    {
        user.recentlyWatched = [NSNumber numberWithInteger:user.recentlyWatched.integerValue+1];
    }
    
    [ShowsOfflineManager updateShowWithShow:nil orUser:user andEntity:@"User"];
}

/**
 This method subtracts 1 to the user's profile movies, recent or tvshows properties based on the type that it receives as parameter and then calls the method to update the user profile
 
 @param type The type to be updated
 */
+(void)removeShowFromUser:(NSString *)type
{
    User *user = [ShowsOfflineManager allUsers].firstObject;
    
    if([type isEqualToString:MOVIES])
    {
        user.movies = [NSNumber numberWithInteger:user.movies.integerValue-1];
    }
    else if([type isEqualToString:TV_SHOWS])
    {
        user.tvShows = [NSNumber numberWithInteger:user.tvShows.integerValue-1];
    }
    else
    {
        user.recentlyWatched = [NSNumber numberWithInteger:user.recentlyWatched.integerValue-1];
    }
    
    [ShowsOfflineManager updateShowWithShow:nil orUser:user andEntity:@"User"];
}


/**
 This method will first check if the user already exist if yes then it updates it, otherwise it deletes all core data information and then creates the user

 @param user The user to be created
 @return Returns the appDelegat saveContext result
 */
+ (BOOL)createUserWithUser:(User *)user {
    
    if([ShowsOfflineManager checkIfUserExists:user])
    {
        return [ShowsOfflineManager updateShowWithShow:nil orUser:user andEntity:@"User"];

    }
    else
    {
        
        [ShowsOfflineManager deleteAllObjects:@"User"];
        [ShowsOfflineManager deleteAllObjects:@"Recent"];
        [ShowsOfflineManager deleteAllObjects:@"TvShow"];
        [ShowsOfflineManager deleteAllObjects:@"Movie"];
        [ShowsOfflineManager deleteAllObjects:@"OfflineChanges"];
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
        
        UserMO *userMO = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        userMO.userId = user.userId.integerValue;
        userMO.username = user.userName;
        userMO.password = user.password;
        userMO.fullname = user.fullName;
        userMO.email = user.email;
        userMO.premium = user.premium.integerValue;
        userMO.thumbnail = [ShowsOfflineManager saveImage:user.thumbnail orImage:nil];
        userMO.recentlyWatched = user.recentlyWatched.integerValue;
        userMO.movies = user.movies.integerValue;
        userMO.tvShows = user.tvShows.integerValue;
        userMO.total = user.tvShows.integerValue;
        
        return [appDelegate saveContext];
    }
}


/**
 This method checks if a given user already exists

 @param user The user to be checked
 @return Return yes if it exists, or no if it does not exist
 */
+(BOOL)checkIfUserExists:(User *)user
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = %ld",user.userId.integerValue];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setEntity:entityDescription];
    
    NSArray *arrResult = [context executeFetchRequest:fetchRequest error:nil];
    
    return arrResult.count > 0;
}

/**
 This method checks if a given show already exists
 
 @param show The show to be checked
 @return Return yes if it exists, or no if it does not exist
 */
+(BOOL)checkIfShowExists:(Show *)show andEntity:(NSString *)entity
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"showId = %ld",show.showId.integerValue];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setEntity:entityDescription];
    
    NSArray *arrResult = [context executeFetchRequest:fetchRequest error:nil];
    
    return arrResult.count > 0;
}


/**
 This method will return all user in core data (it's always 0 or 1 as it can only be one user data at a time)

 @return Returns an NSMutableArray
 */
+ (NSMutableArray<User *> *)allUsers {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *moviesFetch = [UserMO fetchRequest];
    
    NSArray <UserMO *> *users = [context executeFetchRequest:moviesFetch error:nil];
    NSMutableArray <User *> *allUsers = [NSMutableArray new];
    
    for (UserMO *userMO in users) {
        User *user = [User new];
        user.userId = [NSNumber numberWithInteger:userMO.userId];
        user.userName = userMO.username;
        user.password = userMO.password;
        user.fullName = userMO.fullname;
        user.email = userMO.email;
        user.premium = [NSNumber numberWithInteger:userMO.premium];
        user.thumbnail = userMO.thumbnail;
        user.recentlyWatched = [NSNumber numberWithInteger:userMO.recentlyWatched];
        user.movies = [NSNumber numberWithInteger:userMO.movies];
        user.tvShows = [NSNumber numberWithInteger:userMO.tvShows];
        user.total = [NSNumber numberWithInteger:userMO.total];
        [allUsers addObject:user];
    }
    return allUsers;
}


/**
 This method first checks if a given show already exists, if so then it updates it otherwise it creates it

 @param show The show to be created
 @param entity The entity in wich the show should be created
 @return Returns appDelegate saveContext result
 */
+ (BOOL)createShowWithShow:(Show *)show andEntity:(NSString *)entity {
    
    if([ShowsOfflineManager checkIfShowExists:show andEntity:entity])
    {
        return [ShowsOfflineManager updateShowWithShow:show orUser:nil andEntity:entity];
    }
    else
    {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
        
        if([entity isEqualToString:@"Movie"])
        {
            MovieMO *movie = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
            movie.showId = show.showId.integerValue;
            movie.title = show.title;
            movie.watchedTime = show.watchedTime;
            movie.completed = show.completed.integerValue;
            movie.type = show.type;
            movie.imageFileName = [show.thumbnail containsString:@"http"] ? [ShowsOfflineManager saveImage:show.thumbnail orImage:nil] : show.thumbnail;
        }else if([entity isEqualToString:@"TvShow"])
        {
            TvShowMO *tvShow = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
            tvShow.showId = show.showId.integerValue;
            tvShow.title = show.title;
            tvShow.watchedTime = show.watchedTime;
            tvShow.type = show.type;
            tvShow.season = show.season;
            tvShow.episode = show.episode;
            tvShow.completed = show.completed.integerValue;
            tvShow.imageFileName = [show.thumbnail containsString:@"http"] ? [ShowsOfflineManager saveImage:show.thumbnail orImage:nil] : show.thumbnail;
        }else
        {
            RecentMO *recent = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
            recent.showId = show.showId.integerValue;
            recent.title = show.title;
            recent.watchedTime = show.watchedTime;
            recent.type = show.type;
            if([show.type isEqualToString:@"tvshow"])
            {
                recent.season = show.season;
                recent.episode = show.episode;
            }
            recent.completed = show.completed.integerValue;
            recent.imageFileName = [show.thumbnail containsString:@"http"] ? [ShowsOfflineManager saveImage:show.thumbnail orImage:nil] : show.thumbnail;
        }
        
        return [appDelegate saveContext];
    }
}


/**
 This method returns all the shows of an entity

 @param entity The entity to be used to fetch the shows
 @return Returns a NSMutable array with the shows if there are any
 */
+ (NSMutableArray<Show *> *)allResultsWithEntity:(NSString *)entity {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *resultsFetch;
    NSMutableArray <Show *> *allResults = [NSMutableArray new];
    
    if([entity isEqualToString:@"Movie"])
    {
        resultsFetch = [MovieMO fetchRequest];
        NSArray <MovieMO *> *movies = [context executeFetchRequest:resultsFetch error:nil];
        
        for (MovieMO *movie in movies) {
            Show *show = [Show new];
            show.showId = [NSNumber numberWithInteger:movie.showId];
            show.title = movie.title;
            show.type = movie.type;
            show.watchedTime = movie.watchedTime;
            show.completed = [NSNumber numberWithInteger:movie.completed];
            show.thumbnail = movie.imageFileName;
            
            [allResults addObject:show];
        }
    }else if([entity isEqualToString:@"TvShow"])
    {
        resultsFetch = [TvShowMO fetchRequest];
        NSArray <TvShowMO *> *tvshows = [context executeFetchRequest:resultsFetch error:nil];
        for (TvShowMO *tvShow in tvshows) {
            Show * show = [Show new];
            show.showId = [NSNumber numberWithInteger:tvShow.showId];
            show.title = tvShow.title;
            show.type = tvShow.type;
            show.watchedTime = tvShow.watchedTime;
            show.completed = [NSNumber numberWithInteger:tvShow.completed];
            show.season = tvShow.season;
            show.episode = tvShow.episode;
            show.thumbnail = tvShow.imageFileName;
            
            [allResults addObject:show];
        }
    }else
    {
        resultsFetch = [RecentMO fetchRequest];
        NSArray <RecentMO *> *recents = [context executeFetchRequest:resultsFetch error:nil];
        for (RecentMO *recent in recents) {
            Show * show = [Show new];
            show.showId = [NSNumber numberWithInteger:recent.showId];
            show.title = recent.title;
            show.type = recent.type;
            show.watchedTime = recent.watchedTime;
            show.completed = [NSNumber numberWithInteger:recent.completed];
            show.season = recent.season;
            show.episode = recent.episode;
            show.thumbnail = recent.imageFileName;
            
            [allResults addObject:show];
        }
    }
    
    
    return allResults;
}


/**
 This method deletes a show from a given entity

 @param show The show to be deleted
 @param entity The entity that the show belongs to
 */
+(void)deleteShow:(Show *)show withEntity:(NSString *)entity
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"showId = %@",show.showId];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setPredicate:predicate];
    NSArray *items = [context executeFetchRequest:fetchRequest error:nil];
    
    for (NSManagedObject *managedObject in items)
    {
        [context deleteObject:managedObject];
    }
}

+(NSString *)imageNameForShow:(Show *)show withEntity:(NSString *)entity
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"showId = %@",show.showId];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setPredicate:predicate];
    NSArray *items = [context executeFetchRequest:fetchRequest error:nil];
    
    if([entity isEqualToString:@"Movie"])
    {
        RecentMO *recent = items.firstObject;
        return recent.imageFileName;
    }else if([entity isEqualToString:@"TvShow"])
    {
        TvShowMO *tvShow = items.firstObject;
        return tvShow.imageFileName;
    }else
    {
        MovieMO *movie = items.firstObject;
        return movie.imageFileName;
    }
}


/**
 This method deletes an offline change object

 @param change The change to be deleted
 */
+(void)deleteOfflineChange:(OfflineChangesMO *)change
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"OfflineChanges"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idChange = %ld",change.idChange];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setPredicate:predicate];
    NSArray *items = [context executeFetchRequest:fetchRequest error:nil];
    
    for (NSManagedObject *managedObject in items)
    {
        [context deleteObject:managedObject];
    }
}


/**
 This method updates a show or a user, based on an entity that it receives

 @param show The show to be updated (can be nil)
 @param user The user to be updated (can be nil)
 @param entity The entity to be used
 @return Returns the appDelegate saveContext result
 */
+ (BOOL)updateShowWithShow:(Show *)show orUser:(User *)user andEntity:(NSString *)entity
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:context];
    NSPredicate *predicate = show ? [NSPredicate predicateWithFormat:@"showId = %ld",show.showId.integerValue] : [NSPredicate predicateWithFormat:@"userId = %ld",user.userId.integerValue];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setEntity:entityDescription];
    
    NSArray *arrResult = [context executeFetchRequest:fetchRequest error:nil];
    if([entity isEqualToString:@"Movie"])
    {
        MovieMO *movie = arrResult[0];
        movie.showId = show.showId.integerValue;
        movie.title = show.title;
        movie.type = show.type;
        movie.watchedTime = show.watchedTime;
        movie.completed = show.completed.integerValue;
        movie.imageFileName = movie.imageFileName;
    }else if([entity isEqualToString:@"TvShow"])
    {
        TvShowMO *tvshow = arrResult[0];
        tvshow.showId = show.showId.integerValue;
        tvshow.title = show.title;
        tvshow.watchedTime = show.watchedTime;
        tvshow.season = show.season;
        tvshow.episode = show.episode;
        tvshow.type = show.type;
        tvshow.completed = show.completed.integerValue;
    }else if([entity isEqualToString:@"Recent"])
    {
        RecentMO *recent = arrResult[0];
        recent.showId = show.showId.integerValue;
        recent.title = show.title;
        recent.watchedTime = show.watchedTime;
        if([show.type isEqualToString:@"tvshow"])
        {
            recent.season = show.season;
            recent.episode = show.episode;
        }
        recent.type = show.type;
        recent.completed = show.completed.integerValue;
    }else
    {
        UserMO *userMO = arrResult[0];
        userMO.username = user.userName ? user.userName : userMO.username;
        userMO.password = user.password ? user.password : userMO.password;
        userMO.fullname = user.fullName ? user.fullName : userMO.fullname;
        userMO.email = user.email ? user.email : userMO.email;
        userMO.premium = user.premium ? user.premium.integerValue : userMO.premium;
        userMO.thumbnail = [user.thumbnail containsString:@"http"] ? [ShowsOfflineManager saveImage:user.thumbnail orImage:nil] : user.thumbnail;
        userMO.recentlyWatched = user.recentlyWatched ? user.recentlyWatched.integerValue : userMO.recentlyWatched;
        userMO.movies = user.movies ? user.movies.integerValue : userMO.movies;
        userMO.tvShows = user.tvShows ? user.tvShows.integerValue : userMO.tvShows;
        userMO.total = userMO.movies + userMO.tvShows + userMO.recentlyWatched;
    }
    
    return [appDelegate saveContext];
}


/**
 This method creates an offline data change

 @param idToChange The id of the change, it can be a tvshow, movie id or an user id
 @param type The type of change (so the server knows what it is) ex: profile, tvshows, movies etc...
 @param content The content of the change (A semi-colon separated string)
 @return Returns the appDelegate saveContext result
 */
+ (BOOL)createOfflineDataChangeWithId:(NSInteger)idToChange type:(NSString *)type andContent:(NSString *)content {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    OfflineChangesMO *offline = [NSEntityDescription insertNewObjectForEntityForName:@"OfflineChanges" inManagedObjectContext:context];
    offline.idChange = idToChange;
    offline.type = type;
    offline.content = content;
    
    return [appDelegate saveContext];
}


/**
 This method gets all the offline changes objects

 @return Returns an array of offline changes objects
 */
+ (NSArray<OfflineChangesMO *> *)allOfflineChanges {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    NSFetchRequest *offlineFetch = [OfflineChangesMO fetchRequest];
    
    NSArray <OfflineChangesMO *> *offlineChanges = [context executeFetchRequest:offlineFetch error:nil];
    
    return offlineChanges;
}


/**
 This method deletes all objects of an entity

 @param entityName The entity to delete the objects from
 */
+ (void)deleteAllObjects:(NSString *)entityName {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSError *error;
    NSArray *items = [context executeFetchRequest:request error:&error];
    
    for (NSManagedObject *managedObject in items)
    {
        [context deleteObject:managedObject];
    }
    if(![context save:&error]){
        NSLog(@"Error deleting: %@ - error: %@",entityName,error);
    }
}


/**
 This method can save an image to the phone memory from an url or from an UIImage, and returns the file name string

 @param imageURL The url to the image to be saved (it can be nil)
 @param image The UIImage to be saved (it can be nil)
 @return Returns a string with the file name
 */
+ (NSString *)saveImage:(NSString *)imageURL orImage:(UIImage *)image {
    
    NSURL *url = [NSURL URLWithString:imageURL];
    NSData *imageData = imageURL != nil ? [NSData dataWithContentsOfURL:url] : UIImagePNGRepresentation(image);
    NSNumber *randomNumber = [NSNumber numberWithInteger:arc4random_uniform(MAX_RANDOM_NUMER)];
    NSNumber *anotherRandomNumber = [NSNumber numberWithInteger:arc4random_uniform(MAX_RANDOM_NUMER)];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"ddMMyyyyHHmmss"];
    NSDate *currentDate = [NSDate date];
    NSString *dateString = [formatter stringFromDate:currentDate];
    NSString *photoName = [NSString stringWithFormat:@"%@%@%@.jpg",randomNumber,dateString,anotherRandomNumber];
    
    NSURL *photoUrl = [ShowsOfflineManager urlForPhotoName:photoName];
    [imageData writeToURL:photoUrl atomically:YES];
    
    return photoName;

}


/**
 This method gets the url of an image with its file name

 @param photoName The image filename
 @return Returns the image url
 */
+ (NSURL *)urlForPhotoName:(NSString *)photoName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *docsURL = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSURL *photoURL = [docsURL URLByAppendingPathComponent:photoName];
    return photoURL;
}


/**
 This method fetchs the image of a show or user

 @param show The show to be used (it can be nil)
 @param user The user to be used (it can be nil)
 @return Returns the UIImage, or nil if it cannot find it
 */
+ (UIImage *)imageForShow:(Show *)show orUser:(User *)user {
    
    NSString *imageToFetch = show.thumbnail ? show.thumbnail : user.thumbnail;
    
    if (imageToFetch) {
        NSURL *photoUrl = [ShowsOfflineManager urlForPhotoName:imageToFetch];
        
        NSLog(@"%@", photoUrl.path);
        
        return [UIImage imageWithContentsOfFile:photoUrl.path];
    } else {
        return nil;
    }
}

@end
