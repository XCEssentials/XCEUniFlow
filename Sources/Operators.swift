/*
 
 MIT License
 
 Copyright (c) 2016 Maxim Khatskevich (maxim@khatskevi.ch)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

// MARK: - GET data from GlobalModel

public
func << <S: State>(_: S.Type, global: GlobalModel) -> S?
{
    return try? global.state(ofType: S.self)
}

//===

public
func << <F: Feature>(_: F.Type, global: GlobalModel) -> SomeState?
{
    return try? global.state(for: F.self)
}

//===

public
func >> <F: Feature>(global: GlobalModel, _: F.Type) -> SomeState?
{
    return try? global.state(for: F.self)
}

//===

public
func >> <F, S>(global: GlobalModel, _: F.Type) -> S?
    where
    S: State,
    S.Parent == F
{
    return try? global.state(for: F.self)
}

//===

public
func >> <S: State>(global: GlobalModel, _: S.Type) -> S?
{
    return try? global.state(ofType: S.self)
}

// MARK: - Submit action to proxy

public
func << (proxy: Dispatcher.Proxy, action: Action)
{
    proxy.submit(action)
}

//===

public
func << (proxy: Dispatcher.Proxy, actions: [Action])
{
    actions.forEach{ proxy.submit($0) }
}

//===

public
func << (proxy: Dispatcher.Proxy, actionGetter: () -> Action)
{
    proxy.submit(actionGetter())
}

//===

public
func << (proxy: Dispatcher.Proxy, actionGetters: [() -> Action])
{
    actionGetters.forEach{ proxy.submit($0()) }
}

// MARK: - Pass action to 'submit' handler

public
func << (submit: SubmitAction, action: Action)
{
    submit(action)
}

//===

public
func << (submit: SubmitAction, actions: [Action])
{
    actions.forEach{ submit($0) }
}

//===

public
func << (submit: SubmitAction, actionGetters: [() -> Action])
{
    actionGetters.forEach{ submit($0()) }
}

//===

public
func << (submit: SubmitAction, actionGetter: () -> Action)
{
    submit(actionGetter())
}

// MARK: - Pass feature state to 'become' handler

public
func << <S: State>(become: Become<S>, state: S)
{
    become(state)
}
