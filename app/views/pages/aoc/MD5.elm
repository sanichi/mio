module MD5 where

import Native.MD5

md5 : String -> String
md5 = Native.MD5.md5
