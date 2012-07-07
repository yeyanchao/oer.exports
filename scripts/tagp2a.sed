:begin
/<li class="listitem">/,/<\/li>/ { 
   /<\/li>/! { 
       $! {
            N;    
            b begin
        } 
   }  
         s/\(<li class="listitem">.*\)<p>\(.*\)<\/p>\(.*<\/li>\)/\1<a>\2<\/a>\3/;
}

