Parse.Cloud.beforeSave('Item', function(request, response) {
                       var query = new Parse.Query("Item");
                       query.equalTo("Major",request.object.get("Major"));
                       query.equalTo("Minor",request.object.get("Minor"));
                       query.first({
                                   success: function(object)
                                   {
                                    if (object){
                                        if(request.object.id != null)
                                        {
                                                response.success();
                                        }
                                        else
                                        {
                                            var userID = request.object.get("UserId");
                                            if (userID == object.get("UserId"))
                                            { // if it already belongs to the user it's good
                                                response.error("You added it before");
                                            }
                                            else
                                            { // otherwise it already exists and it belongs to someone else
                                                response.error("This Item added by another before");
                                            }

                                        }
                                    }
                                    else
                                    { // If the object doesn't exist at all it's available
                                        response.success();
                                    }
                                   },
                                   error: function(error) {
                                   response.error("Could not validate uniqueness for this uniqueColumn.");
                                   }
                                   });     
                       });



