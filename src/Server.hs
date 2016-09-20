{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE OverloadedStrings   #-}

module Server where

import           Control.Monad.Except
import           Data.Aeson
import           Data.Aeson.TH
import qualified Data.ByteString.Char8    as BSC
import           Data.Text                (Text)
import qualified Data.Text                as T
import           Data.Time
import           Data.UUID.V4
import           Network.URI
import           Network.Wai
import           Network.Wai.Handler.Warp
import           Servant
import           Servant.Docs             hiding (API)
import           Servant.Server

import           API
import           Types

startApp :: IO ()
startApp = run 8080 app

app :: Application
app = serve fullApi server

fullApi :: Proxy FullAPI
fullApi = Proxy

api :: Proxy API
api = Proxy

server :: Server FullAPI
server = serveDocs :<|> index :<|> getAllUsers :<|> getAllBooks

serveDocs :: ExceptT ServantErr IO Text
serveDocs = return $ T.pack $ markdown $ docs $ pretty api

getAllUsers :: ExceptT ServantErr IO [User]
getAllUsers = do
  urAWizard <- liftIO nextRandom
  return [User "Harry Potter" (InternalId urAWizard)]

getAllBooks :: ExceptT ServantErr IO [Book]
getAllBooks = do
  now <- liftIO getCurrentTime
  return [Book "lol-legit-isbn" "A Story of Sadness" ["Emily Olorin", "Oswyn Brent"] ["Sadness Publishing"] now]

index :: ExceptT ServantErr IO a
index = do
  let redirectURI = safeLink fullApi (Proxy :: Proxy Docs)
  throwError $ err301{errHeaders=("Location", BSC.pack $ show redirectURI):errHeaders err301}
