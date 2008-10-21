= goaloc

* FIX (url)

== DESCRIPTION:

This is Generate on a Lot of Crack, which started its life as a more powerful script/generate for rails.

== FEATURES/PROBLEMS:

* FIX (list of features or problems)

== SYNOPSIS:

Goaloc was motivated by the fact that to make a nested resource (ie, to get  /posts/1/comments to resolve), one must specify the relation between post and comment in 4 places:  the routes, the migration, and in both models.  That's silly, and not so DRY.  Enter GoaLoC, and the "blog in 15 minutes" talk essentially reduces to:

goaloc myblog
>> route [:posts, :comments]
>> Post.add_attrs "body:text title:string"
>> Comment.add_attrs "body:text"
>> generate

== REQUIREMENTS:

shoulda to run tests, possibly ruby2ruby in the future.

== INSTALL:

* FIX (sudo gem install, anything else)

== LICENSE:

(The MIT License)

Copyright (c) 2008 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
