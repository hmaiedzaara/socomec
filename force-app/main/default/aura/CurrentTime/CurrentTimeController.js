({
	getDateNTime : function(component, event, helper) {
		var action = component.get("c.getDateTime");
        
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            
            if (state === "SUCCESS") 
            {
                var sec = 0;
                var tz;
                var tzwe;
                var dto;
                //console.log("From server: " + response.getReturnValue());
                //console.log("From server: " + response.getReturnValue());
                var i = setTimeout( function() 
                {
                   console.log("Interval "+sec);
                   var dt = component.get("v.dt");
                   //console.log("Interval "+sec+ "dt: " +dt);
                   if(dt!=undefined && false)
                   {
                       var dtJS = new Date(dt);
                       //console.log(' time is: '+dtJS);
                       if(tz!=undefined) {
                           dtJS.setHours(dtJS.getHours()+tz);
                           if(tz%1 == (0.5) || tz%1 == (-0.5))
                           	dtJS.setMinutes(dtJS.getMinutes()+30);
                           tz=undefined;
                       }
                       //console.log(' time is now: '+dtJS);
                       sec = dtJS.getSeconds()+1;
                       dtJS.setSeconds(sec);
                       //console.log("Interval IN "+dtJS+ 'm: '+tz);
                       var ftime = (''+dtJS).substring(0,(''+dtJS).lastIndexOf(':')+3);
                       component.set("v.dt", ''+ftime);
                       component.set("v.time", ftime.substring(ftime.length-8));
                       
                       var localen = "en-us";
    				   var monthname = dtJS.toLocaleString(localen, { month: "long" });
                       component.set("v.month", monthname);
                       if(sec==60)
                       {
                           sec=0;
                       }
                   }
                   else
                   {
                       
                       //clearInterval(i);
                       var rv = response.getReturnValue();
                       dto = JSON.parse(rv);
                       
                       console.log(rv);
                      // dto = new Date(dto);
                       
                      // tz = parseFloat(dto.timezone)/100;
                      // var d = new Date();
                      // var minutes = d.getTimezoneOffset();
                      //// var hd = minutes / 60;
                      // tz = hd+tz;
                       //dto = new Date(dto);
                       //dto.setMinutes(60);
                       
                   	   component.set("v.dt", rv);
                       component.set("v.dt", dto.fulldate);
                       component.set("v.day", dto.day);
                       component.set("v.date", dto.date);
                       component.set("v.month", dto.month);
                       component.set("v.year", dto.year);
                       component.set("v.time", dto.time);
                       component.set("v.timezoneR", dto.timezoneR);
                       component.set("v.timezone", ''+dto.timezone);
                       
                       tz = parseFloat(dto.timezone)/100;
                       var d = new Date();
                       var minutes = d.getTimezoneOffset();
                       var hd = minutes / 60;
                       tz = hd+tz;
                       console.log("TZ is  "+tz);
                       $A.enqueueAction(action);
                       
                   }
                   
                }, 1000);
                
            }
            else if (state === "ERROR") 
            {
                var errors = response.getError();
                if (errors) 
                {
                    console.log(' errors: '+JSON.stringify(errors));
                    $A.logf("Errors", errors);
                    if (errors[0] && errors[0].message) 
                    {
                        $A.error("Error message: " + errors[0].message);
                    }
                } 
                else 
                {
                    $A.error("Unknown error");
                }
            }
        }
        );
        $A.enqueueAction(action);
	}
})