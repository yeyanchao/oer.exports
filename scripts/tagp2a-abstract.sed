:begin
/<li class="abstract">/,/<\/p>/ { 
   /<\/p>/! { 
       $! {
            N;    
            b begin
        } 
   }  
         s/\(<li class="abstract">.*\)<p>\(.*\)<\/p>/\1<a>\2<\/a>/;
}

