module Frontend.Check where

import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import Control.Monad.Trans.Class
import Control.Monad.Trans.State
import Control.Monad.Trans.Except
import Data.Functor.Identity
import qualified AbsLatte


data Context = Context {
  -- maps variables names to their types in the current context
  typeof :: Map.Map AbsLatte.Ident Register
  block :: Set AbsLatte.Ident
}

type Verification = ExceptT Instructions (StateT Env Identity)


newReg :: Type -> Env -> (Env, Register)
newReg t (Env bs regC)= (Env bs (regC + 1), Reg t ("r" ++ show regC))


bindVar :: Instant.Ident -> Register -> Env -> Env
bindVar var reg env = Env (Map.insert var reg (bindings env)) (regCount env)


bindVarM :: Instant.Ident -> Register -> Compilation ()
bindVarM var reg = do
  env <- lift get
  lift $ put $ bindVar var reg env


getVarM :: Instant.Ident -> Compilation (Maybe Register)
getVarM var = do
  env <- lift get
  return $ Map.lookup var (bindings env)


newRegM :: Type -> Compilation Register
newRegM t = do
  env <- lift get
  let (nenv, reg) = newReg t env
  lift $ put nenv
  return reg
