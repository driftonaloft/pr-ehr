module user;

import vibe.db.mongo.mongo;
import vibe.data.serialization : name;
import vibe.data.bson;
import vibe.vibe;

import database;


struct UserInfo {
    @name("_id") BsonObjectID id;
    string userName;
    string password;
    string [] permissions;

    void addPermissions(string [] permissionsToAdd){
        foreach(ref p; permissionsToAdd){
            bool doAdd = true;
            foreach(per; permissions){
                if(p == per){
                    doAdd = false;
                    break;
                }
            }
            if(doAdd){
                permissions ~= p;
            }
        }
    }

    void removePermissions(string [] permissionsToRemove) {
        string [] temppermissions;
        foreach(permission; permissions){
            bool keep = true;
            foreach(perm; permissionsToRemove) {
                if(perm == permission){
                    keep = false;
                    break;
                }
            }
            if(keep) {
                temppermissions ~= permission;
            }
        }
        permissions = temppermissions;
    }
    bool active;
}


class User {
    UserInfo info;
    Database db;

    long clientCount;

    this (Database db_) {
        db = db_;
    }

    @property {
        string userName (string value){
            info.userName = value;
            //updateUser();
            return info.userName;
        }
        string userName(){
            return info.userName;
        }
    }

    bool permissions(string permission){
        foreach(p; info.permissions){
            if(p == permission){
                return true;
            }
        }
        return false;
    }

    bool permissions(string [] permissions){
        foreach(ref p; info.permissions){
            foreach(ref p2; permissions){
                if(p2 == p){
                    return true;
                }
            }
        }
        return false;
    }

    bool getUserInfo(string username) {
        auto cursor = db.users.find(["userName": username]);
        if(cursor.empty){ 
            return false;   
        }
        auto currentInfo = cursor.front;
        info = deserialize!(BsonSerializer, UserInfo)(currentInfo);
        return true;
    }

    bool createUser(string username, string password, string [] permissions){     
        auto cursor = db.users.find(["userName": username]);
        
        if(!cursor.empty){ 
            return false;   
        }

        info.id = BsonObjectID.generate();
        info.userName = username;
        info.password = password;
        info.permissions = permissions;
        info.active = true;

        try {
            db.users.insertOne(info.serializeToBson());
        } catch (Exception e){
            logError("Error creating user: %s", e.msg);
        }
  
        return true;
    }

    bool updateUser(){ //called via properties setters to update the user in the db 
        try{
            db.users.updateOne(["_id": info.id], info.serializeToBson());
        } catch (Exception e){
            logError("Error updating user: %s", e.msg);
        }
        return true;
    }
}


class UserManager {
    Database db;

    User[] activeUsers;


    this (Database db_) {
        db = db_;
    }

    void startup(){
        logInfo("UserCount: %d", userCount);
        if (userCount()  == 0) {
            logInfo("Creating admin user");
            createUser("admin", "d34dz0n3", ["user","admin"]);
        }
    }

    User getUser(string username){
        foreach(ref u; activeUsers){
            if(u.userName == username){
                return u;
            }
        }

        auto user = new User(db);
        if(user.getUserInfo(username)){
            user.clientCount++;
            return user;
        }
        return null;
    }

    User getUserClient(string username, string password){
        foreach(ref u; activeUsers){
            if(u.userName == username){
                u.clientCount++;
                return u;
            }
        }

        //TODO: serperate this for get user for client reference
        auto user = new User(db);
        if(user.getUserInfo(username)){
            if(user.info.password != password){
                return null;
            }
            user.clientCount++;
            activeUsers ~= user;
            return user;
        }
        return null;
    }

    User createUser(string username, string password, string [] permissions){
        auto user = new User(db);
        if (user.createUser(username, password, permissions)) {
            return user;
        }
        return null;
    }

    User [] getUserList(int count=100, int start=0){
        User [] users;
        FindOptions fo;
        fo.limit = count;
        fo.skip = start;
        foreach(user; db.users.find!UserInfo()){
            auto tempUser = new User(db);
            tempUser.info = user;
            users ~= tempUser;
        }
        return users;
    }

    void disconnectUser(ref User user){
        import std.algorithm.mutation;
        user.clientCount--;
        if(user.clientCount == 0){
            user.updateUser();
        }
        activeUsers = activeUsers.remove!(u => u.userName == user.userName && user.clientCount == 0 );
    }

    size_t userCount(){
        size_t count;
        foreach(user; db.users.find!UserInfo()){
            count++;
        }
        return count;
    }
}


